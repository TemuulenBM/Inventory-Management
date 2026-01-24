-- ============================================================================
-- Trusted Devices Table
-- Хэрэглэгчийн итгэмжилсэн төхөөрөмжүүдийг хадгална
-- Device trust feature-д ашиглана (OTP skip)
-- ============================================================================

CREATE TABLE IF NOT EXISTS trusted_devices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    device_id VARCHAR(255) NOT NULL,
    device_name VARCHAR(255),
    trusted_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_used_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, device_id)
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_trusted_devices_user_id ON trusted_devices(user_id);
CREATE INDEX IF NOT EXISTS idx_trusted_devices_device_id ON trusted_devices(device_id);

-- Comments
COMMENT ON TABLE trusted_devices IS 'Итгэмжлэгдсэн төхөөрөмжүүд - OTP skip хийхэд ашиглана';
COMMENT ON COLUMN trusted_devices.device_id IS 'Төхөөрөмжийн UUID (Flutter app-аас үүсгэгдсэн)';
COMMENT ON COLUMN trusted_devices.device_name IS 'Төхөөрөмжийн нэр (optional, e.g., iPhone 15)';
COMMENT ON COLUMN trusted_devices.trusted_at IS 'Итгэмжлэгдсэн огноо';
COMMENT ON COLUMN trusted_devices.last_used_at IS 'Сүүлд ашигласан огноо';

-- RLS Policy
ALTER TABLE trusted_devices ENABLE ROW LEVEL SECURITY;

-- Users can only see/manage their own trusted devices
CREATE POLICY "Users can manage own trusted devices"
    ON trusted_devices
    FOR ALL
    USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());
