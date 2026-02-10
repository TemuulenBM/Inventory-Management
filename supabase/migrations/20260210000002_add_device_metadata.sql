-- ============================================================================
-- trusted_devices: device_info metadata column нэмэх
-- Асуудал: Зөвхөн device_id хадгалагддаг — хулгайлагдсан device_id-г
--          өөр platform-аас ашиглахаас сэргийлэх metadata шалгалт шаардлагатай
-- ============================================================================

ALTER TABLE trusted_devices ADD COLUMN IF NOT EXISTS device_info JSONB DEFAULT '{}';

COMMENT ON COLUMN trusted_devices.device_info IS 'Төхөөрөмжийн мэдээлэл: platform, model, osVersion (login үед шалгана)';
