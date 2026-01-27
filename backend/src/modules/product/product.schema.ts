/**
 * Product Module - Zod Validation Schemas
 *
 * Product CRUD validation schemas.
 */

import { z } from 'zod';

/**
 * Create Product Schema
 * POST /stores/:storeId/products body validation
 */
export const createProductSchema = z.object({
  name: z.string().min(1).max(200).describe('Барааны нэр'),
  sku: z.string().min(1).max(100).optional().describe('SKU код (давхардахгүй)'),
  unit: z.enum(['piece', 'kg', 'g', 'liter', 'ml', 'pack', 'box', 'bottle', 'other']).describe('Хэмжих нэгж'),
  costPrice: z.number().min(0).describe('Өртөг (авсан үнэ)'),
  sellPrice: z.number().min(0).describe('Зарах үнэ'),
  lowStockThreshold: z.number().int().min(0).optional().describe('Бага үлдэгдлийн босго'),
  category: z.string().min(1).max(100).optional().describe('Барааны ангилал'),
});

export type CreateProductBody = z.infer<typeof createProductSchema>;

/**
 * Update Product Schema
 * PUT /stores/:storeId/products/:productId body validation
 */
export const updateProductSchema = z.object({
  name: z.string().min(1).max(200).optional().describe('Барааны нэр'),
  sku: z.string().min(1).max(100).optional().describe('SKU код'),
  unit: z.enum(['piece', 'kg', 'g', 'liter', 'ml', 'pack', 'box', 'bottle', 'other']).optional().describe('Хэмжих нэгж'),
  costPrice: z.number().min(0).optional().describe('Өртөг'),
  sellPrice: z.number().min(0).optional().describe('Зарах үнэ'),
  lowStockThreshold: z.number().int().min(0).optional().describe('Бага үлдэгдлийн босго'),
  category: z.string().min(1).max(100).optional().describe('Барааны ангилал'),
});

export type UpdateProductBody = z.infer<typeof updateProductSchema>;

/**
 * Bulk Create Products Schema
 * POST /stores/:storeId/products/bulk body validation
 */
export const bulkCreateProductsSchema = z.object({
  products: z.array(createProductSchema).min(1).max(100).describe('Барааны жагсаалт (max 100)'),
});

export type BulkCreateProductsBody = z.infer<typeof bulkCreateProductsSchema>;

/**
 * Product Query Params Schema
 * GET /stores/:storeId/products query validation
 */
export const productQuerySchema = z.object({
  page: z.coerce.number().int().min(1).default(1).describe('Хуудас'),
  limit: z.coerce.number().int().min(1).max(100).default(20).describe('Хуудас бүрт харуулах тоо'),
  search: z.string().optional().describe('Хайлт (нэр, SKU)'),
  unit: z.enum(['piece', 'kg', 'g', 'liter', 'ml', 'pack', 'box', 'bottle', 'other']).optional().describe('Хэмжих нэгжээр шүүх'),
  lowStock: z.coerce.boolean().optional().describe('Зөвхөн бага үлдэгдэлтэй бараа'),
});

export type ProductQueryParams = z.infer<typeof productQuerySchema>;

/**
 * Product Response Types
 */

// Product мэдээлэл
export interface ProductInfo {
  id: string;
  storeId: string;
  name: string;
  sku: string | null;
  unit: string;
  costPrice: number;
  sellPrice: number;
  lowStockThreshold: number | null;
  category: string | null;
  imageUrl: string | null;
  createdAt: string;
}

// Product with stock level
export interface ProductWithStock extends ProductInfo {
  currentStock: number;
  isLowStock: boolean;
}

// Products list response
export interface ProductsListResponse {
  success: true;
  products: ProductWithStock[];
  pagination: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
}

// Single product response
export interface ProductResponse {
  success: true;
  product: ProductInfo;
}

// Bulk create response
export interface BulkCreateResponse {
  success: true;
  created: number;
  products: ProductInfo[];
}
