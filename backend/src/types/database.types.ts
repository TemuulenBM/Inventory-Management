export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  // Allows to automatically instantiate createClient with right options
  // instead of createClient<Database, { PostgrestVersion: 'XX' }>(URL, KEY)
  __InternalSupabase: {
    PostgrestVersion: "14.1"
  }
  public: {
    Tables: {
      alerts: {
        Row: {
          alert_type: string
          created_at: string | null
          id: string
          level: string | null
          message: string
          product_id: string | null
          resolved: boolean | null
          resolved_at: string | null
          store_id: string
        }
        Insert: {
          alert_type: string
          created_at?: string | null
          id?: string
          level?: string | null
          message: string
          product_id?: string | null
          resolved?: boolean | null
          resolved_at?: string | null
          store_id: string
        }
        Update: {
          alert_type?: string
          created_at?: string | null
          id?: string
          level?: string | null
          message?: string
          product_id?: string | null
          resolved?: boolean | null
          resolved_at?: string | null
          store_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "alerts_product_id_fkey"
            columns: ["product_id"]
            isOneToOne: false
            referencedRelation: "product_stock_levels"
            referencedColumns: ["product_id"]
          },
          {
            foreignKeyName: "alerts_product_id_fkey"
            columns: ["product_id"]
            isOneToOne: false
            referencedRelation: "products"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "alerts_store_id_fkey"
            columns: ["store_id"]
            isOneToOne: false
            referencedRelation: "stores"
            referencedColumns: ["id"]
          },
        ]
      }
      inventory_events: {
        Row: {
          actor_id: string
          event_type: string
          id: string
          product_id: string
          qty_change: number
          reason: string | null
          shift_id: string | null
          store_id: string
          synced_at: string | null
          timestamp: string | null
        }
        Insert: {
          actor_id: string
          event_type: string
          id?: string
          product_id: string
          qty_change: number
          reason?: string | null
          shift_id?: string | null
          store_id: string
          synced_at?: string | null
          timestamp?: string | null
        }
        Update: {
          actor_id?: string
          event_type?: string
          id?: string
          product_id?: string
          qty_change?: number
          reason?: string | null
          shift_id?: string | null
          store_id?: string
          synced_at?: string | null
          timestamp?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "inventory_events_actor_id_fkey"
            columns: ["actor_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "inventory_events_product_id_fkey"
            columns: ["product_id"]
            isOneToOne: false
            referencedRelation: "product_stock_levels"
            referencedColumns: ["product_id"]
          },
          {
            foreignKeyName: "inventory_events_product_id_fkey"
            columns: ["product_id"]
            isOneToOne: false
            referencedRelation: "products"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "inventory_events_shift_id_fkey"
            columns: ["shift_id"]
            isOneToOne: false
            referencedRelation: "shifts"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "inventory_events_store_id_fkey"
            columns: ["store_id"]
            isOneToOne: false
            referencedRelation: "stores"
            referencedColumns: ["id"]
          },
        ]
      }
      invitations: {
        Row: {
          created_at: string | null
          expires_at: string
          id: string
          invited_at: string | null
          invited_by: string | null
          phone: string
          role: string
          status: string
          updated_at: string | null
          used_at: string | null
          used_by: string | null
        }
        Insert: {
          created_at?: string | null
          expires_at: string
          id?: string
          invited_at?: string | null
          invited_by?: string | null
          phone: string
          role?: string
          status?: string
          updated_at?: string | null
          used_at?: string | null
          used_by?: string | null
        }
        Update: {
          created_at?: string | null
          expires_at?: string
          id?: string
          invited_at?: string | null
          invited_by?: string | null
          phone?: string
          role?: string
          status?: string
          updated_at?: string | null
          used_at?: string | null
          used_by?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "invitations_invited_by_fkey"
            columns: ["invited_by"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "invitations_used_by_fkey"
            columns: ["used_by"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      otp_tokens: {
        Row: {
          attempt_count: number
          created_at: string | null
          expires_at: string
          id: number
          otp_code: string
          phone: string
          verified: boolean | null
        }
        Insert: {
          attempt_count?: number
          created_at?: string | null
          expires_at: string
          id?: number
          otp_code: string
          phone: string
          verified?: boolean | null
        }
        Update: {
          attempt_count?: number
          created_at?: string | null
          expires_at?: string
          id?: number
          otp_code?: string
          phone?: string
          verified?: boolean | null
        }
        Relationships: []
      }
      products: {
        Row: {
          category: string | null
          cost_price: number | null
          created_at: string | null
          id: string
          image_url: string | null
          is_deleted: boolean | null
          low_stock_threshold: number | null
          name: string
          note: string | null
          sell_price: number
          sku: string
          store_id: string
          unit: string
          updated_at: string | null
        }
        Insert: {
          category?: string | null
          cost_price?: number | null
          created_at?: string | null
          id?: string
          image_url?: string | null
          is_deleted?: boolean | null
          low_stock_threshold?: number | null
          name: string
          note?: string | null
          sell_price: number
          sku: string
          store_id: string
          unit: string
          updated_at?: string | null
        }
        Update: {
          category?: string | null
          cost_price?: number | null
          created_at?: string | null
          id?: string
          image_url?: string | null
          is_deleted?: boolean | null
          low_stock_threshold?: number | null
          name?: string
          note?: string | null
          sell_price?: number
          sku?: string
          store_id?: string
          unit?: string
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "products_store_id_fkey"
            columns: ["store_id"]
            isOneToOne: false
            referencedRelation: "stores"
            referencedColumns: ["id"]
          },
        ]
      }
      sale_items: {
        Row: {
          id: string
          product_id: string
          quantity: number
          sale_id: string
          subtotal: number
          unit_price: number
        }
        Insert: {
          id?: string
          product_id: string
          quantity: number
          sale_id: string
          subtotal: number
          unit_price: number
        }
        Update: {
          id?: string
          product_id?: string
          quantity?: number
          sale_id?: string
          subtotal?: number
          unit_price?: number
        }
        Relationships: [
          {
            foreignKeyName: "sale_items_product_id_fkey"
            columns: ["product_id"]
            isOneToOne: false
            referencedRelation: "product_stock_levels"
            referencedColumns: ["product_id"]
          },
          {
            foreignKeyName: "sale_items_product_id_fkey"
            columns: ["product_id"]
            isOneToOne: false
            referencedRelation: "products"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "sale_items_sale_id_fkey"
            columns: ["sale_id"]
            isOneToOne: false
            referencedRelation: "sales"
            referencedColumns: ["id"]
          },
        ]
      }
      sales: {
        Row: {
          id: string
          payment_method: string | null
          seller_id: string
          shift_id: string | null
          store_id: string
          synced_at: string | null
          timestamp: string | null
          total_amount: number
        }
        Insert: {
          id?: string
          payment_method?: string | null
          seller_id: string
          shift_id?: string | null
          store_id: string
          synced_at?: string | null
          timestamp?: string | null
          total_amount: number
        }
        Update: {
          id?: string
          payment_method?: string | null
          seller_id?: string
          shift_id?: string | null
          store_id?: string
          synced_at?: string | null
          timestamp?: string | null
          total_amount?: number
        }
        Relationships: [
          {
            foreignKeyName: "sales_seller_id_fkey"
            columns: ["seller_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "sales_shift_id_fkey"
            columns: ["shift_id"]
            isOneToOne: false
            referencedRelation: "shifts"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "sales_store_id_fkey"
            columns: ["store_id"]
            isOneToOne: false
            referencedRelation: "stores"
            referencedColumns: ["id"]
          },
        ]
      }
      shifts: {
        Row: {
          close_balance: number | null
          closed_at: string | null
          id: string
          open_balance: number | null
          opened_at: string | null
          seller_id: string
          store_id: string
          synced_at: string | null
        }
        Insert: {
          close_balance?: number | null
          closed_at?: string | null
          id?: string
          open_balance?: number | null
          opened_at?: string | null
          seller_id: string
          store_id: string
          synced_at?: string | null
        }
        Update: {
          close_balance?: number | null
          closed_at?: string | null
          id?: string
          open_balance?: number | null
          opened_at?: string | null
          seller_id?: string
          store_id?: string
          synced_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "shifts_seller_id_fkey"
            columns: ["seller_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "shifts_store_id_fkey"
            columns: ["store_id"]
            isOneToOne: false
            referencedRelation: "stores"
            referencedColumns: ["id"]
          },
        ]
      }
      store_members: {
        Row: {
          created_at: string | null
          id: string
          role: string
          store_id: string
          user_id: string
        }
        Insert: {
          created_at?: string | null
          id?: string
          role: string
          store_id: string
          user_id: string
        }
        Update: {
          created_at?: string | null
          id?: string
          role?: string
          store_id?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "store_members_store_id_fkey"
            columns: ["store_id"]
            isOneToOne: false
            referencedRelation: "stores"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "store_members_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      stores: {
        Row: {
          created_at: string | null
          id: string
          location: string | null
          name: string
          owner_id: string
          timezone: string | null
          updated_at: string | null
        }
        Insert: {
          created_at?: string | null
          id?: string
          location?: string | null
          name: string
          owner_id: string
          timezone?: string | null
          updated_at?: string | null
        }
        Update: {
          created_at?: string | null
          id?: string
          location?: string | null
          name?: string
          owner_id?: string
          timezone?: string | null
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "fk_stores_owner_id"
            columns: ["owner_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      sync_log: {
        Row: {
          conflict_resolved: boolean | null
          device_id: string | null
          entity_id: string | null
          entity_type: string
          error_message: string | null
          id: number
          operation: string
          payload: Json
          store_id: string
          sync_timestamp: string | null
        }
        Insert: {
          conflict_resolved?: boolean | null
          device_id?: string | null
          entity_id?: string | null
          entity_type: string
          error_message?: string | null
          id?: number
          operation: string
          payload: Json
          store_id: string
          sync_timestamp?: string | null
        }
        Update: {
          conflict_resolved?: boolean | null
          device_id?: string | null
          entity_id?: string | null
          entity_type?: string
          error_message?: string | null
          id?: number
          operation?: string
          payload?: Json
          store_id?: string
          sync_timestamp?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "sync_log_store_id_fkey"
            columns: ["store_id"]
            isOneToOne: false
            referencedRelation: "stores"
            referencedColumns: ["id"]
          },
        ]
      }
      transfer_items: {
        Row: {
          id: string
          product_id: string
          quantity: number
          transfer_id: string
        }
        Insert: {
          id?: string
          product_id: string
          quantity: number
          transfer_id: string
        }
        Update: {
          id?: string
          product_id?: string
          quantity?: number
          transfer_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "transfer_items_product_id_fkey"
            columns: ["product_id"]
            isOneToOne: false
            referencedRelation: "product_stock_levels"
            referencedColumns: ["product_id"]
          },
          {
            foreignKeyName: "transfer_items_product_id_fkey"
            columns: ["product_id"]
            isOneToOne: false
            referencedRelation: "products"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "transfer_items_transfer_id_fkey"
            columns: ["transfer_id"]
            isOneToOne: false
            referencedRelation: "transfers"
            referencedColumns: ["id"]
          },
        ]
      }
      transfers: {
        Row: {
          completed_at: string | null
          created_at: string | null
          destination_store_id: string
          id: string
          initiated_by: string
          notes: string | null
          source_store_id: string
          status: string
        }
        Insert: {
          completed_at?: string | null
          created_at?: string | null
          destination_store_id: string
          id?: string
          initiated_by: string
          notes?: string | null
          source_store_id: string
          status?: string
        }
        Update: {
          completed_at?: string | null
          created_at?: string | null
          destination_store_id?: string
          id?: string
          initiated_by?: string
          notes?: string | null
          source_store_id?: string
          status?: string
        }
        Relationships: [
          {
            foreignKeyName: "transfers_destination_store_id_fkey"
            columns: ["destination_store_id"]
            isOneToOne: false
            referencedRelation: "stores"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "transfers_initiated_by_fkey"
            columns: ["initiated_by"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "transfers_source_store_id_fkey"
            columns: ["source_store_id"]
            isOneToOne: false
            referencedRelation: "stores"
            referencedColumns: ["id"]
          },
        ]
      }
      trusted_devices: {
        Row: {
          device_id: string
          device_info: Json | null
          device_name: string | null
          id: string
          last_used_at: string | null
          trusted_at: string | null
          user_id: string
        }
        Insert: {
          device_id: string
          device_info?: Json | null
          device_name?: string | null
          id?: string
          last_used_at?: string | null
          trusted_at?: string | null
          user_id: string
        }
        Update: {
          device_id?: string
          device_info?: Json | null
          device_name?: string | null
          id?: string
          last_used_at?: string | null
          trusted_at?: string | null
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "trusted_devices_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      users: {
        Row: {
          created_at: string | null
          id: string
          last_online: string | null
          name: string
          password_hash: string | null
          phone: string | null
          role: string
          store_id: string | null
          updated_at: string | null
        }
        Insert: {
          created_at?: string | null
          id?: string
          last_online?: string | null
          name: string
          password_hash?: string | null
          phone?: string | null
          role: string
          store_id?: string | null
          updated_at?: string | null
        }
        Update: {
          created_at?: string | null
          id?: string
          last_online?: string | null
          name?: string
          password_hash?: string | null
          phone?: string | null
          role?: string
          store_id?: string | null
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "users_store_id_fkey"
            columns: ["store_id"]
            isOneToOne: false
            referencedRelation: "stores"
            referencedColumns: ["id"]
          },
        ]
      }
    }
    Views: {
      product_stock_levels: {
        Row: {
          current_stock: number | null
          is_low_stock: boolean | null
          last_updated: string | null
          low_stock_threshold: number | null
          product_id: string | null
          product_name: string | null
          sku: string | null
          store_id: string | null
        }
        Relationships: [
          {
            foreignKeyName: "products_store_id_fkey"
            columns: ["store_id"]
            isOneToOne: false
            referencedRelation: "stores"
            referencedColumns: ["id"]
          },
        ]
      }
    }
    Functions: {
      expire_old_invitations: { Args: never; Returns: undefined }
      refresh_product_stock_levels: { Args: never; Returns: undefined }
      user_has_store_access: {
        Args: { check_store_id: string }
        Returns: boolean
      }
      user_store_id: { Args: never; Returns: string }
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  public: {
    Enums: {},
  },
} as const
