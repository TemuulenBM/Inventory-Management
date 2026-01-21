/**
 * Database Seed Script
 *
 * Test өгөгдөл үүсгэнэ:
 * - 1 Test Store (Temuulen's Shop)
 * - 3 Users (Owner, Manager, Seller)
 * - 10 Products (Mongolian retail items)
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

  for (const table of tables) {
    const { error } = await supabase.from(table as any).delete().neq('id', '00000000-0000-0000-0000-000000000000');

    if (error && !error.message.includes('not found')) {
      log(`   ⚠️  Error clearing ${table}: ${error.message}`, 'red');
    } else {
      log(`   ✓ ${table} cleared`, 'green');
    }
  }
}

async function seedStore() {
  log('\n📦 Creating test store...', 'blue');

  const storeId = generateId();
  const ownerId = generateId(); // Owner ID-г store үүсгэхээс өмнө бэлдэх

  const store: StoreInsert = {
    id: storeId,
    name: "Temuulen's Retail Shop",
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
  log('\n🛒 Creating test products...', 'blue');

  const products: ProductInsert[] = [
    {
      id: generateId(),
      store_id: storeId,
      name: 'Сүү (1L)',
      sku: 'MILK-1L',
      unit: 'piece',
      cost_price: 1500,
      sell_price: 2000,
      low_stock_threshold: 10,
    },
    {
      id: generateId(),
      store_id: storeId,
      name: 'Талх (Хар)',
      sku: 'BREAD-BLACK',
      unit: 'piece',
      cost_price: 800,
      sell_price: 1200,
      low_stock_threshold: 20,
    },
    {
      id: generateId(),
      store_id: storeId,
      name: 'Өндөг (10 ширхэг)',
      sku: 'EGG-10',
      unit: 'pack',
      cost_price: 3000,
      sell_price: 4000,
      low_stock_threshold: 5,
    },
    {
      id: generateId(),
      store_id: storeId,
      name: 'Кока Кола (1.5L)',
      sku: 'COKE-1.5L',
      unit: 'bottle',
      cost_price: 2000,
      sell_price: 3000,
      low_stock_threshold: 15,
    },
    {
      id: generateId(),
      store_id: storeId,
      name: 'Будаа (1кг)',
      sku: 'RICE-1KG',
      unit: 'kg',
      cost_price: 2500,
      sell_price: 3500,
      low_stock_threshold: 10,
    },
    {
      id: generateId(),
      store_id: storeId,
      name: 'Гурил (1кг)',
      sku: 'FLOUR-1KG',
      unit: 'kg',
      cost_price: 1800,
      sell_price: 2500,
      low_stock_threshold: 10,
    },
    {
      id: generateId(),
      store_id: storeId,
      name: 'Шанага (АПУ)',
      sku: 'NOODLES-APU',
      unit: 'piece',
      cost_price: 500,
      sell_price: 800,
      low_stock_threshold: 30,
    },
    {
      id: generateId(),
      store_id: storeId,
      name: 'Цай (100 уутанцар)',
      sku: 'TEA-100',
      unit: 'box',
      cost_price: 3000,
      sell_price: 4500,
      low_stock_threshold: 5,
    },
    {
      id: generateId(),
      store_id: storeId,
      name: 'Элсэн чихэр (1кг)',
      sku: 'SUGAR-1KG',
      unit: 'kg',
      cost_price: 2200,
      sell_price: 3000,
      low_stock_threshold: 10,
    },
    {
      id: generateId(),
      store_id: storeId,
      name: 'Үзмийн дарс (Монгол)',
      sku: 'WINE-MGL',
      unit: 'bottle',
      cost_price: 15000,
      sell_price: 25000,
      low_stock_threshold: 3,
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

    // 2. Create store
    const { storeId, ownerId } = await seedStore();

    // 3. Create users
    await seedUsers(storeId, ownerId);

    // 4. Create products
    const products = await seedProducts(storeId);

    // 5. Create initial inventory
    await seedInventoryEvents(storeId, ownerId, products);

    // 6. Verify
    await verifyData(storeId);

    log('\n' + '='.repeat(50), 'green');
    log('✅ Database Seeding Completed Successfully!', 'green');
    log('\nТа одоо эдгээр test өгөгдлийг ашиглан API develop хийж болно.\n', 'blue');
  } catch (error) {
    log('\n❌ Seeding failed:', 'red');
    console.error(error);
    process.exit(1);
  }
}

// Run
main();
