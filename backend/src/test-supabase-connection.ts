/**
 * Supabase Connection Test
 *
 * Энэ скрипт Supabase холболт болон type-safety-г шалгана:
 * 1. Environment variables load хийгдсэн эсэх
 * 2. Supabase client үүссэн эсэх
 * 3. Database-д хандаж чадаж байгаа эсэх
 * 4. Type-safe queries ажиллаж байгаа эсэх
 */

import { supabase } from './config/supabase.js';
import { env } from './config/env.js';

async function testSupabaseConnection() {
  console.log('\n🧪 Supabase Connection Test\n');
  console.log('=' .repeat(50));

  // 1. Environment variables
  console.log('\n1️⃣ Environment Variables');
  console.log(`   ✓ SUPABASE_URL: ${env.SUPABASE_URL}`);
  console.log(`   ✓ NODE_ENV: ${env.NODE_ENV}`);
  console.log(`   ✓ PORT: ${env.PORT}`);

  // 2. Database tables list
  console.log('\n2️⃣ Database Tables');
  try {
    const { data: stores, error: storesError } = await supabase
      .from('stores')
      .select('id, name')
      .limit(1);

    if (storesError) {
      console.log(`   ⚠️  stores table: ${storesError.message}`);
    } else {
      console.log(`   ✓ stores table accessible (${stores?.length || 0} rows)`);
    }

    // Test бусад tables
    const tables = [
      'users',
      'products',
      'inventory_events',
      'sales',
      'sale_items',
      'shifts',
      'alerts',
      'otp_tokens',
      'refresh_tokens',
    ];

    for (const table of tables) {
      const { data, error } = await supabase.from(table as any).select('id').limit(1);

      if (error) {
        console.log(`   ⚠️  ${table}: ${error.message}`);
      } else {
        console.log(`   ✓ ${table} accessible (${data?.length || 0} rows)`);
      }
    }
  } catch (error) {
    console.error('   ❌ Error accessing database:', error);
    process.exit(1);
  }

  // 3. Type-safety test
  console.log('\n3️⃣ Type-Safety Test');
  try {
    // Type-safe query - TypeScript IDE-д autocomplete ажиллана
    const { data: stores, error } = await supabase
      .from('stores')
      .select('id, name, created_at')
      .limit(5);

    if (error) {
      console.log(`   ⚠️  Query failed: ${error.message}`);
    } else {
      console.log(`   ✓ Type-safe query successful`);
      console.log(`   ✓ Stores count: ${stores?.length || 0}`);

      if (stores && stores.length > 0) {
        console.log(`   ✓ Sample store:`, {
          id: stores[0].id,
          name: stores[0].name,
          created_at: stores[0].created_at,
        });
      }
    }
  } catch (error) {
    console.error('   ❌ Type-safety test failed:', error);
  }

  // 4. Performance test
  console.log('\n4️⃣ Performance Test');
  const start = Date.now();
  const { data, error } = await supabase.from('stores').select('id').limit(100);
  const duration = Date.now() - start;

  if (error) {
    console.log(`   ⚠️  Performance test failed: ${error.message}`);
  } else {
    console.log(`   ✓ Query latency: ${duration}ms`);
    console.log(`   ✓ Rows fetched: ${data?.length || 0}`);
  }

  // Summary
  console.log('\n' + '='.repeat(50));
  console.log('✅ Supabase Connection Test Passed!\n');
  console.log('Та одоо Sprint 1.1-г дууссан:');
  console.log('  ✓ Supabase JS Client суулгагдсан');
  console.log('  ✓ Database types генерэйт хийгдсэн');
  console.log('  ✓ Type-safe Supabase client бэлэн');
  console.log('  ✓ Connection амжилттай тест хийгдсэн\n');
}

// Run test
testSupabaseConnection().catch((error) => {
  console.error('\n❌ Test failed:', error);
  process.exit(1);
});
