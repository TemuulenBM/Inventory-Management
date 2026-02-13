/**
 * Shift Service
 *
 * Business logic for shift management:
 * - Open shift
 * - Close shift
 * - List shifts
 * - Get shift details
 * - Get active shift
 */

import { supabase } from '../../config/supabase.js';
import type { OpenShiftBody, CloseShiftBody, ShiftQueryParams } from './shift.schema.js';
import { createAlert } from '../alerts/alerts.service.js';

type ServiceResult<T> =
  | { success: true } & T
  | { success: false; error: string };

/**
 * Ээлж нээх
 * - Seller нэг л идэвхтэй ээлжтэй байж болно
 * - Хуучин ээлж хаагдаагүй бол шинэ нээж болохгүй
 */
export async function openShift(
  storeId: string,
  sellerId: string,
  data: OpenShiftBody
): Promise<ServiceResult<{ shift: any }>> {
  try {
    // 1. Худалдагч тухайн дэлгүүрт харьяалагдаж байгаа эсэхийг шалгах
    const { data: user, error: userError } = await supabase
      .from('users')
      .select('id, role, store_id')
      .eq('id', sellerId)
      .eq('store_id', storeId)
      .single();

    if (userError || !user) {
      return { success: false, error: 'Хэрэглэгч олдсонгүй' };
    }

    // 2. Идэвхтэй ээлж байгаа эсэхийг шалгах
    const { data: activeShifts } = await supabase
      .from('shifts')
      .select('id')
      .eq('store_id', storeId)
      .eq('seller_id', sellerId)
      .is('closed_at', null);

    // Олон идэвхтэй ээлж олдвол data integrity алдаа
    if (activeShifts && activeShifts.length > 1) {
      console.error(`❌ Multiple active shifts detected for seller ${sellerId}: ${activeShifts.length} shifts`);
      return {
        success: false,
        error: 'Өгөгдлийн алдаа: олон идэвхтэй ээлж байна. Админтай холбогдоно уу.'
      };
    }

    if (activeShifts && activeShifts.length === 1) {
      return { success: false, error: 'Та аль хэдийн идэвхтэй ээлжтэй байна' };
    }

    // 3. Шинэ ээлж үүсгэх
    const { data: shift, error: shiftError } = await supabase
      .from('shifts')
      .insert({
        store_id: storeId,
        seller_id: sellerId,
        open_balance: data.open_balance ?? null,
        synced_at: new Date().toISOString(), // Sync timestamp auto-set
      })
      .select()
      .single();

    if (shiftError || !shift) {
      return { success: false, error: 'Ээлж нээхэд алдаа гарлаа' };
    }

    return {
      success: true,
      shift: {
        id: shift.id,
        store_id: shift.store_id,
        seller_id: shift.seller_id,
        opened_at: shift.opened_at,
        closed_at: shift.closed_at,
        open_balance: shift.open_balance,
        close_balance: shift.close_balance,
      },
    };
  } catch (error) {
    return { success: false, error: 'Серверийн алдаа' };
  }
}

/**
 * Ээлж хаах
 * - Идэвхтэй ээлж байгаа эсэхийг шалгана
 * - Борлуулалтын нийт дүн, тоог тооцоолно
 */
export async function closeShift(
  storeId: string,
  sellerId: string,
  data: CloseShiftBody
): Promise<ServiceResult<{ shift: any }>> {
  try {
    // 1. Идэвхтэй ээлж олох
    const { data: shift, error: shiftError } = await supabase
      .from('shifts')
      .select('id, store_id, seller_id, opened_at, open_balance')
      .eq('store_id', storeId)
      .eq('seller_id', sellerId)
      .is('closed_at', null)
      .single();

    if (shiftError || !shift) {
      return { success: false, error: 'Идэвхтэй ээлж олдсонгүй' };
    }

    // 2. Ээлжийн борлуулалтуудыг тооцоолох
    const { data: sales } = await supabase
      .from('sales')
      .select('total_amount, payment_method')
      .eq('shift_id', shift.id);

    const totalSales = sales?.reduce((sum, sale) => sum + parseFloat(String(sale.total_amount)), 0) ?? 0;
    const totalSalesCount = sales?.length ?? 0;

    // 3. Мөнгөн тулгалт (cash reconciliation) тооцоолох
    // Бэлэн мөнгөний борлуулалт (зөвхөн cash payment method)
    const cashSales = (sales ?? [])
      .filter((sale) => sale.payment_method === 'cash')
      .reduce((sum, sale) => sum + parseFloat(String(sale.total_amount)), 0);

    const openBalance = shift.open_balance ? parseFloat(String(shift.open_balance)) : 0;
    const expectedBalance = openBalance + cashSales;
    const closeBalance = data.close_balance ?? null;
    // Зөрүү: бодит тоолсон мөнгө - хүлээгдэж буй мөнгө
    const discrepancy = closeBalance !== null ? closeBalance - expectedBalance : null;

    // 4. Ээлж хаах (тулгалтын тоогоор хамт)
    const { data: closedShift, error: closeError } = await supabase
      .from('shifts')
      .update({
        closed_at: new Date().toISOString(),
        close_balance: closeBalance,
        expected_balance: expectedBalance,
        discrepancy: discrepancy,
        synced_at: new Date().toISOString(),
      })
      .eq('id', shift.id)
      .select()
      .single();

    if (closeError || !closedShift) {
      return { success: false, error: 'Ээлж хаахад алдаа гарлаа' };
    }

    // 5. Мөнгөн зөрүү ихтэй бол ALERT үүсгэх (₮5,000-с дээш)
    if (discrepancy !== null && Math.abs(discrepancy) > 5000) {
      // Худалдагчийн нэр авах
      const { data: seller } = await supabase
        .from('users')
        .select('name')
        .eq('id', shift.seller_id)
        .single();
      const sellerName = seller?.name ?? 'Тодорхойгүй';

      const alertLevel = Math.abs(discrepancy) > 20000 ? 'critical' as const : 'warning' as const;
      await createAlert(storeId, {
        alert_type: 'cash_discrepancy',
        message: `Худалдагч "${sellerName}" ээлжийн мөнгөн тулгалт зөрүүтэй: ₮${discrepancy.toLocaleString()} (хүлээгдэж буй: ₮${expectedBalance.toLocaleString()}, бодит: ₮${closeBalance?.toLocaleString() ?? '?'})`,
        level: alertLevel,
      });
    }

    // 6. Бараа тоолж тулгах (сонголттой)
    if (data.inventory_counts && data.inventory_counts.length > 0) {
      // a) Тоолсон бараануудын системийн нөөцийн тоо авах
      const productIds = data.inventory_counts.map(c => c.product_id);
      const { data: stockLevels } = await supabase
        .from('product_stock_levels')
        .select('product_id, current_stock')
        .in('product_id', productIds);

      const stockMap = new Map<string, number>(
        (stockLevels ?? []).map(s => [s.product_id, s.current_stock ?? 0])
      );

      // b) shift_inventory_counts хүснэгтэд хадгалах
      const counts = data.inventory_counts.map(c => ({
        shift_id: shift.id,
        store_id: storeId,
        product_id: c.product_id,
        physical_count: c.physical_count,
        system_count: stockMap.get(c.product_id) ?? 0,
        counted_by: sellerId,
      }));

      const { error: insertError } = await supabase
        .from('shift_inventory_counts')
        .insert(counts);

      if (insertError) {
        // Тоолгын мэдээлэл хадгалж чадаагүй ч ээлж хаагдсан
        // Log хийгээд үргэлжлүүлнэ (ээлж хаах амжилттай болсон)
        console.error('Бараа тоолгын мэдээлэл хадгалахад алдаа:', insertError.message);
      } else {
        // c) 3-с дээш зөрүүтэй бараа байвал alert үүсгэх
        const criticalItems = counts.filter(c =>
          Math.abs(c.physical_count - c.system_count) >= 3
        );

        if (criticalItems.length > 0) {
          // Бараануудын нэр авах
          const { data: products } = await supabase
            .from('products')
            .select('id, name')
            .in('id', criticalItems.map(c => c.product_id));

          const productNames = new Map<string, string>(
            (products ?? []).map(p => [p.id, p.name])
          );

          const itemsList = criticalItems.map(c => {
            const disc = c.physical_count - c.system_count;
            const name = productNames.get(c.product_id) ?? 'Тодорхойгүй';
            return `${name}: ${disc > 0 ? '+' : ''}${disc}`;
          }).join(', ');

          const alertLevel = criticalItems.length >= 5 ? 'critical' as const : 'warning' as const;
          await createAlert(storeId, {
            alert_type: 'inventory_discrepancy',
            message: `Ээлжийн бараа тулгалт зөрүүтэй (${criticalItems.length} бараа): ${itemsList}`,
            level: alertLevel,
          });
        }
      }
    }

    return {
      success: true,
      shift: {
        id: closedShift.id,
        store_id: closedShift.store_id,
        seller_id: closedShift.seller_id,
        opened_at: closedShift.opened_at,
        closed_at: closedShift.closed_at,
        open_balance: closedShift.open_balance,
        close_balance: closedShift.close_balance,
        expected_balance: expectedBalance,
        discrepancy: discrepancy,
        total_sales: totalSales,
        total_sales_count: totalSalesCount,
      },
    };
  } catch (error) {
    return { success: false, error: 'Серверийн алдаа' };
  }
}

/**
 * Тухайн ээлжийн бараа тоолгын зөрүүг авах
 */
export async function getShiftInventoryCounts(
  shiftId: string,
  storeId: string
): Promise<ServiceResult<{ counts: any[]; summary: any }>> {
  try {
    const { data: counts, error } = await supabase
      .from('shift_inventory_counts')
      .select('*, products!inner(name, sku)')
      .eq('shift_id', shiftId)
      .eq('store_id', storeId)
      .order('counted_at', { ascending: true });

    if (error) {
      return { success: false, error: 'Тоолгын мэдээлэл авахад алдаа гарлаа' };
    }

    const countsData = (counts ?? []).map((c: any) => ({
      id: c.id,
      product_id: c.product_id,
      product_name: c.products?.name ?? '',
      product_sku: c.products?.sku ?? '',
      physical_count: c.physical_count,
      system_count: c.system_count,
      discrepancy: c.discrepancy,
      counted_at: c.counted_at,
      notes: c.notes,
    }));

    // Хураангуй тооцоолох
    let totalMissing = 0;
    let totalExcess = 0;
    let totalDiscrepancies = 0;

    for (const c of countsData) {
      if (c.discrepancy < 0) totalMissing += Math.abs(c.discrepancy);
      if (c.discrepancy > 0) totalExcess += c.discrepancy;
      if (c.discrepancy !== 0) totalDiscrepancies++;
    }

    return {
      success: true,
      counts: countsData,
      summary: {
        total_counted: countsData.length,
        total_discrepancies: totalDiscrepancies,
        total_missing: totalMissing,
        total_excess: totalExcess,
      },
    };
  } catch (error) {
    return { success: false, error: 'Серверийн алдаа' };
  }
}

/**
 * Ээлжийн түүх авах
 */
export async function getShifts(
  storeId: string,
  query: ShiftQueryParams
): Promise<ServiceResult<{ shifts: any[]; pagination: any }>> {
  try {
    // 1. Query үүсгэх
    let queryBuilder = supabase
      .from('shifts')
      .select('*, users!inner(name)', { count: 'exact' })
      .eq('store_id', storeId)
      .order('opened_at', { ascending: false });

    // Seller filter
    if (query.seller_id) {
      queryBuilder = queryBuilder.eq('seller_id', query.seller_id);
    }

    // Pagination
    queryBuilder = queryBuilder.range(query.offset, query.offset + query.limit - 1);

    const { data: shifts, error, count } = await queryBuilder;

    if (error || !shifts) {
      return { success: false, error: 'Ээлжийн түүх авахад алдаа гарлаа' };
    }

    // 2. Response format
    const formattedShifts = shifts.map((shift: any) => ({
      id: shift.id,
      store_id: shift.store_id,
      seller_id: shift.seller_id,
      seller_name: shift.users.name,
      opened_at: shift.opened_at,
      closed_at: shift.closed_at,
      open_balance: shift.open_balance,
      close_balance: shift.close_balance,
      expected_balance: shift.expected_balance,
      discrepancy: shift.discrepancy,
      synced_at: shift.synced_at,
    }));

    return {
      success: true,
      shifts: formattedShifts,
      pagination: {
        total: count ?? 0,
        limit: query.limit,
        offset: query.offset,
      },
    };
  } catch (error) {
    return { success: false, error: 'Серверийн алдаа' };
  }
}

/**
 * Ээлж дэлгэрэнгүй авах
 */
export async function getShift(
  shiftId: string,
  storeId: string
): Promise<ServiceResult<{ shift: any }>> {
  try {
    // 1. Ээлж авах
    const { data: shift, error: shiftError } = await supabase
      .from('shifts')
      .select('*, users!inner(name)')
      .eq('id', shiftId)
      .eq('store_id', storeId)
      .single();

    if (shiftError || !shift) {
      return { success: false, error: 'Ээлж олдсонгүй' };
    }

    // 2. Ээлжийн борлуулалтууд
    const { data: sales } = await supabase
      .from('sales')
      .select('id, total_amount, payment_method, timestamp')
      .eq('shift_id', shiftId)
      .order('timestamp', { ascending: false });

    const totalSales = sales?.reduce((sum, sale) => sum + parseFloat(String(sale.total_amount)), 0) ?? 0;
    const totalSalesCount = sales?.length ?? 0;

    return {
      success: true,
      shift: {
        id: shift.id,
        store_id: shift.store_id,
        seller_id: shift.seller_id,
        seller_name: shift.users.name,
        opened_at: shift.opened_at,
        closed_at: shift.closed_at,
        open_balance: shift.open_balance,
        close_balance: shift.close_balance,
        synced_at: shift.synced_at,
        total_sales: totalSales,
        total_sales_count: totalSalesCount,
        sales: sales ?? [],
      },
    };
  } catch (error) {
    return { success: false, error: 'Серверийн алдаа' };
  }
}

/**
 * Идэвхтэй ээлж авах
 */
export async function getActiveShift(
  storeId: string,
  sellerId: string
): Promise<ServiceResult<{ shift: any | null }>> {
  try {
    // 1. Идэвхтэй ээлж олох (fallback pattern: олон мөр байвал хамгийн сүүлийнхийг авна)
    const { data: shifts } = await supabase
      .from('shifts')
      .select('*, users!inner(name)')
      .eq('store_id', storeId)
      .eq('seller_id', sellerId)
      .is('closed_at', null)
      .order('opened_at', { ascending: false })
      .limit(1);

    // Warning log хэрэв олон идэвхтэй ээлж байвал (unique constraint нэмэх migration дутуу гүйсэн байж болно)
    if (shifts && shifts.length > 1) {
      console.warn(`⚠️ Multiple active shifts found for seller ${sellerId}: ${shifts.length} shifts`);
    }

    const shift = shifts?.[0] || null;

    if (!shift) {
      return { success: true, shift: null };
    }

    // 2. Ээлжийн борлуулалт тооцоолох
    const { data: sales } = await supabase
      .from('sales')
      .select('total_amount')
      .eq('shift_id', shift.id);

    const totalSales = sales?.reduce((sum, sale) => sum + parseFloat(String(sale.total_amount)), 0) ?? 0;
    const totalSalesCount = sales?.length ?? 0;

    return {
      success: true,
      shift: {
        id: shift.id,
        store_id: shift.store_id,
        seller_id: shift.seller_id,
        seller_name: shift.users.name,
        opened_at: shift.opened_at,
        open_balance: shift.open_balance,
        total_sales: totalSales,
        total_sales_count: totalSalesCount,
      },
    };
  } catch (error) {
    return { success: false, error: 'Серверийн алдаа' };
  }
}
