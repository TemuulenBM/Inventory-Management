import { supabase } from './src/config/supabase.js';

async function checkUser() {
  const { data, error } = await supabase
    .from('users')
    .select('id, phone, name, role, store_id')
    .eq('phone', '+97694393494')
    .single();

  if (error) {
    console.error('Error:', error);
  } else {
    console.log('Current user:');
    console.log(JSON.stringify(data, null, 2));
  }
}

checkUser().then(() => process.exit(0));
