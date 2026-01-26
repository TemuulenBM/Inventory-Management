/**
 * Database Seed Script
 *
 * Test өгөгдөл үүсгэнэ:
 * - Super-admin (store-гүй owner)
 * - Test invitation
 * - 1 Test Store (Baby Shop)
 * - 3 Users (Owner, Manager, Seller)
 * - 12 Products (Baby clothing items)
 * - Initial inventory events
 *
 * Ажиллуулах: npm run db:seed
 */

import { supabase } from '../config/supabase.js';
import type {
  StoreInsert,
  UserInsert,
  ProductInsert,
  InventoryEventInsert,
} from '../config/supabase.js';

// Helper: Generate UUID (simple version for demo)
function generateId(): string {
  return crypto.randomUUID();
}

// Өнгөнүүд
const COLORS = {
  reset: '\x1b[0m',
  green: '\x1b[32m',
  blue: '\x1b[34m',
  yellow: '\x1b[33m',
  red: '\x1b[31m',
};

function log(message: string, color: keyof typeof COLORS = 'reset') {
  console.log(`${COLORS[color]}${message}${COLORS.reset}`);
}

async function clearDatabase() {
  log('\n🗑️  Clearing existing data...', 'yellow');

  // Өгөгдлийг дарааллаар устгах (foreign key constraints-ийн улмаас)
  const tables = [
    'inventory_events',
    'sale_items',
    'sales',
    'shifts',
    'alerts',
    'products',
    'users',
    'stores',
    'otp_tokens',
  ] as const;

  // Invitations хүснэгтийг тусад нь устгах
  await supabase.from('invitations').delete().neq('id', '00000000-0000-0000-0000-000000000000');

  for (const table of tables) {
    const { error } = await supabase.from(table as any).delete().neq('id', '00000000-0000-0000-0000-000000000000');

    if (error && !error.message.includes('not found')) {
      log(`   ⚠️  Error clearing ${table}: ${error.message}`, 'red');
    } else {
      log(`   ✓ ${table} cleared`, 'green');
    }
  }
}

async function seedSuperAdmin() {
  log('\n🔑 Creating super-admin owner...', 'blue');

  const superAdminId = generateId();

  // Эхлээд хуучин super-admin байгаа эсэхийг шалгах
  const { data: existingUser } = await supabase
    .from('users')
    .select('id')
    .eq('phone', '+97694393494')
    .single();

  let data;
  if (existingUser) {
    // Байвал UPDATE хийх
    const { data: updatedUser, error: updateError } = await supabase
      .from('users')
      .update({
        name: 'Temuulen (Admin)',
        role: 'super_admin',
        store_id: null,
      })
      .eq('phone', '+97694393494')
      .select()
      .single();

    if (updateError) {
      log(`   ❌ Error: ${updateError.message}`, 'red');
      throw updateError;
    }
    data = updatedUser;
    log(`   ✓ Super-admin updated: ${data.phone}`, 'green');
  } else {
    // Байхгүй бол INSERT хийх
    const superAdmin = {
      id: superAdminId,
      phone: '+97694393494',
      name: 'Temuulen (Admin)',
      role: 'super_admin',
      store_id: null,
      password_hash: null,
    };

    const { data: newUser, error: insertError } = await supabase
      .from('users')
      .insert(superAdmin)
      .select()
      .single();

    if (insertError) {
      log(`   ❌ Error: ${insertError.message}`, 'red');
      throw insertError;
    }
    data = newUser;
    log(`   ✓ Super-admin created: ${data.phone}`, 'green');
  }

  log(`   ✓ Super-admin created: ${data.phone}`, 'green');
  return superAdminId;
}

async function seedTestInvitations(invitedBy: string) {
  log('\n✉️  Creating test invitations...', 'blue');

  const testInvitations = [
    {
      id: generateId(),
      phone: '+97699119911', // Test owner
      role: 'owner',
      invited_by: invitedBy,
      status: 'pending',
      expires_at: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString(), // 30 days
    },
  ];

  const { data, error } = await supabase.from('invitations').insert(testInvitations as any).select();

  if (error) {
    log(`   ❌ Error: ${error.message}`, 'red');
  } else {
    log(`   ✓ ${data.length} invitations created`, 'green');
    data.forEach((inv: any) => {
      log(`     - ${inv.phone} (${inv.role})`, 'green');
    });
  }
}

async function seedStore() {
  log('\n📦 Creating test store...', 'blue');

  const storeId = generateId();
  const ownerId = generateId(); // Owner ID-г store үүсгэхээс өмнө бэлдэх

  const store: StoreInsert = {
    id: storeId,
    name: "Temuulen's Baby Shop",
    location: 'Улаанбаатар, Сүхбаатар дүүрэг',
    owner_id: ownerId,
    timezone: 'Asia/Ulaanbaatar',
  };

  const { data, error } = await supabase.from('stores').insert(store).select().single();

  if (error) {
    log(`   ❌ Error: ${error.message}`, 'red');
    throw error;
  }

  log(`   ✓ Store created: ${data.name} (ID: ${data.id})`, 'green');
  return { storeId: data.id, ownerId };
}

async function seedUsers(storeId: string, ownerId: string) {
  log('\n👥 Creating test users...', 'blue');

  const users: UserInsert[] = [
    {
      id: ownerId, // Store үүсгэхдээ бэлдсэн owner_id ашиглана
      store_id: storeId,
      phone: '+97699119911',
      name: 'Temuulen (Owner)',
      role: 'owner',
      password_hash: null, // Password дараа нь нэмнэ
    },
    {
      id: generateId(),
      store_id: storeId,
      phone: '+97699119922',
      name: 'Bataa (Manager)',
      role: 'manager',
      password_hash: null,
    },
    {
      id: generateId(),
      store_id: storeId,
      phone: '+97699119933',
      name: 'Dorj (Seller)',
      role: 'seller',
      password_hash: null,
    },
  ];

  const { data, error } = await supabase.from('users').insert(users).select();

  if (error) {
    log(`   ❌ Error: ${error.message}`, 'red');
    throw error;
  }

  log(`   ✓ ${data.length} users created`, 'green');
  data.forEach((user) => {
    log(`     - ${user.name} (${user.role})`, 'green');
  });

  return {
    ownerId: data[0].id,
    managerId: data[1].id,
    sellerId: data[2].id,
  };
}

async function seedProducts(storeId: string) {
  log('\n👶 Creating baby clothing products...', 'blue');

  const products: ProductInsert[] = [
    {
      id: generateId(),
      store_id: storeId,
      name: 'Хүүхдийн Боди (0-3 сар, Цагаан)',
      sku: 'BODYSUIT-0-3-WHT',
      unit: 'piece',
      cost_price: 8000,
      sell_price: 12000,
      low_stock_threshold: 10,
      image_url: 'https://images.unsplash.com/photo-1519238109-b95e80677b3f?w=400',
    },
    {
      id: generateId(),
      store_id: storeId,
      name: 'Хүүхдийн Боди (3-6 сар, Ягаан)',
      sku: 'BODYSUIT-3-6-PINK',
      unit: 'piece',
      cost_price: 9000,
      sell_price: 13500,
      low_stock_threshold: 10,
      image_url: 'https://images.unsplash.com/photo-1522771930-78848d9293e8?w=400',
    },
    {
      id: generateId(),
      store_id: storeId,
      name: 'Хүүхдийн Өмд (6-12 сар, Хөх)',
      sku: 'PANTS-6-12-BLUE',
      unit: 'piece',
      cost_price: 12000,
      sell_price: 18000,
      low_stock_threshold: 8,
      image_url: 'https://images.unsplash.com/photo-1503944583220-79d8926ad5e2?w=400',
    },
    {
      id: generateId(),
      store_id: storeId,
      name: 'Охидын Даашинз (6-12 сар, Улаан)',
      sku: 'DRESS-6-12-RED',
      unit: 'piece',
      cost_price: 15000,
      sell_price: 22000,
      low_stock_threshold: 6,
      image_url: 'https://images.unsplash.com/photo-1518831959646-742c3a14ebf7?w=400',
    },
    {
      id: generateId(),
      store_id: storeId,
      name: 'Хүүхдийн Комбинезон (0-3 сар)',
      sku: 'ROMPER-0-3-GRY',
      unit: 'piece',
      cost_price: 18000,
      sell_price: 25000,
      low_stock_threshold: 5,
      image_url: 'https://images.unsplash.com/photo-1515488042361-ee00e0ddd4e4?w=400',
    },
    {
      id: generateId(),
      store_id: storeId,
      name: 'Хүүхдийн Цамц (12-18 сар, Шар)',
      sku: 'SHIRT-12-18-YLW',
      unit: 'piece',
      cost_price: 10000,
      sell_price: 15000,
      low_stock_threshold: 8,
      image_url: 'https://images.unsplash.com/photo-1596394516093-501ba68a0ba6?w=400',
    },
    {
      id: generateId(),
      store_id: storeId,
      name: 'Нойрын Хувцас (6-12 сар)',
      sku: 'SLEEPWEAR-6-12',
      unit: 'set',
      cost_price: 14000,
      sell_price: 20000,
      low_stock_threshold: 7,
      image_url: 'https://images.unsplash.com/photo-1519689373023-dd07c7988603?w=400',
    },
    {
      id: generateId(),
      store_id: storeId,
      name: 'Хүүхдийн Оймс (0-6 сар, Өнгөт)',
      sku: 'SOCKS-0-6-MIX',
      unit: 'pair',
      cost_price: 3000,
      sell_price: 5000,
      low_stock_threshold: 15,
      image_url: 'https://images.unsplash.com/photo-1586363104862-3a5e2ab60d99?w=400',
    },
    {
      id: generateId(),
      store_id: storeId,
      name: 'Хүүхдийн Малгай (Newborn)',
      sku: 'HAT-NB-BRN',
      unit: 'piece',
      cost_price: 5000,
      sell_price: 8000,
      low_stock_threshold: 10,
      image_url: 'https://images.unsplash.com/photo-1607081692251-5f68c6eda402?w=400',
    },
    {
      id: generateId(),
      store_id: storeId,
      name: 'Хүүхдийн Жакет (12-18 сар, Хар)',
      sku: 'JACKET-12-18-BLK',
      unit: 'piece',
      cost_price: 25000,
      sell_price: 35000,
      low_stock_threshold: 5,
      image_url: 'https://images.unsplash.com/photo-1503944583220-79d8926ad5e2?w=400',
    },
    {
      id: generateId(),
      store_id: storeId,
      name: 'Охидын Кардиган (6-12 сар, Ягаан)',
      sku: 'CARDIGAN-6-12-PINK',
      unit: 'piece',
      cost_price: 16000,
      sell_price: 23000,
      low_stock_threshold: 6,
      image_url: 'https://images.unsplash.com/photo-1519340241574-2cec6aef0c01?w=400',
    },
    {
      id: generateId(),
      store_id: storeId,
      name: 'Хөвгүүдийн Шорт (18-24 сар, Цэнхэр)',
      sku: 'SHORTS-18-24-BLUE',
      unit: 'piece',
      cost_price: 9000,
      sell_price: 14000,
      low_stock_threshold: 8,
      image_url: 'https://images.unsplash.com/photo-1519689373023-dd07c7988603?w=400',
    },
  ];

  const { data, error } = await supabase.from('products').insert(products).select();

  if (error) {
    log(`   ❌ Error: ${error.message}`, 'red');
    throw error;
  }

  log(`   ✓ ${data.length} products created`, 'green');
  return data;
}

async function seedInventoryEvents(storeId: string, ownerId: string, products: any[]) {
  log('\n📊 Creating initial inventory events...', 'blue');

  // Бүх бараанд эхний үлдэгдэл өгөх (INITIAL event)
  const events: InventoryEventInsert[] = products.map((product) => ({
    id: generateId(),
    store_id: storeId,
    product_id: product.id,
    actor_id: ownerId,
    event_type: 'INITIAL',
    qty_change: Math.floor(Math.random() * 50) + 20, // 20-70 ширхэг
    reason: 'Анхны бараа бүртгэл',
  }));

  const { data, error } = await supabase.from('inventory_events').insert(events).select();

  if (error) {
    log(`   ❌ Error: ${error.message}`, 'red');
    throw error;
  }

  log(`   ✓ ${data.length} inventory events created`, 'green');

  // Нийт үлдэгдэл тооцоолох
  const totalStock = data.reduce((sum, event) => sum + event.qty_change, 0);
  log(`   ✓ Total initial stock: ${totalStock} units`, 'green');
}

async function verifyData(storeId: string) {
  log('\n✅ Verifying seeded data...', 'blue');

  // Store check
  const { data: store } = await supabase
    .from('stores')
    .select('*')
    .eq('id', storeId)
    .single();

  log(`   ✓ Store: ${store?.name}`, 'green');

  // Users check
  const { data: users } = await supabase
    .from('users')
    .select('*')
    .eq('store_id', storeId);

  log(`   ✓ Users: ${users?.length} (${users?.map((u) => u.role).join(', ')})`, 'green');

  // Products check
  const { data: products } = await supabase
    .from('products')
    .select('*')
    .eq('store_id', storeId);

  log(`   ✓ Products: ${products?.length}`, 'green');

  // Inventory events check
  const { data: events } = await supabase
    .from('inventory_events')
    .select('*')
    .eq('store_id', storeId);

  log(`   ✓ Inventory Events: ${events?.length}`, 'green');

  // Stock calculation check
  if (products && events) {
    log('\n📦 Current Stock Levels:', 'blue');
    for (const product of products.slice(0, 5)) {
      // Зөвхөн эхний 5-г харуулна
      const productEvents = events.filter((e) => e.product_id === product.id);
      const stock = productEvents.reduce((sum, e) => sum + e.qty_change, 0);
      log(`   - ${product.name}: ${stock} ${product.unit}`, 'green');
    }
  }
}

async function main() {
  try {
    log('\n🌱 Database Seeding Started', 'blue');
    log('=' .repeat(50), 'blue');

    // 1. Clear existing data
    await clearDatabase();

    // 2. Create super-admin (store-гүй owner, бүх урилга илгээх эрхтэй)
    const superAdminId = await seedSuperAdmin();

    // 3. Create test invitations
    await seedTestInvitations(superAdminId);

    // 4. Create test store
    const { storeId, ownerId } = await seedStore();

    // 5. Create test users
    await seedUsers(storeId, ownerId);

    // 6. Create test products
    const products = await seedProducts(storeId);

    // 7. Create initial inventory
    await seedInventoryEvents(storeId, ownerId, products);

    // 8. Verify
    await verifyData(storeId);

    log('\n' + '='.repeat(50), 'green');
    log('✅ Database Seeding Completed Successfully!', 'green');
    log('\n📝 Super-admin credentials:', 'blue');
    log('   Phone: +97694393494', 'yellow');
    log('   Нэвтрэхдээ OTP ашиглана\n', 'blue');
    log('📝 Test invitation:', 'blue');
    log('   Phone: +97699119911 (owner role)', 'yellow');
    log('   Энэ дугаар OTP verify хийхэд шинэ owner user үүснэ\n', 'blue');
  } catch (error) {
    log('\n❌ Seeding failed:', 'red');
    console.error(error);
    process.exit(1);
  }
}

// Run
main();
