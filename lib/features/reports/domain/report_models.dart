/// Тайлангийн data models
/// Backend reports endpoint-ын response-г parse хийхэд ашиглана.
/// Plain Dart class + fromJson factory (Freezed ашиглахгүй — read-only data)

/// Өдрийн борлуулалтын тайлан
class DailyReport {
  final String date;
  final double totalSales;
  final int totalSalesCount;
  final int totalItemsSold;
  final List<PaymentMethodBreakdown> paymentMethods;
  final List<HourlyBreakdown> hourlyBreakdown;

  const DailyReport({
    required this.date,
    required this.totalSales,
    required this.totalSalesCount,
    required this.totalItemsSold,
    required this.paymentMethods,
    required this.hourlyBreakdown,
  });

  factory DailyReport.fromJson(Map<String, dynamic> json) {
    return DailyReport(
      date: json['date'] as String? ?? '',
      totalSales: (json['total_sales'] as num?)?.toDouble() ?? 0,
      totalSalesCount: (json['total_sales_count'] as num?)?.toInt() ?? 0,
      totalItemsSold: (json['total_items_sold'] as num?)?.toInt() ?? 0,
      paymentMethods: (json['payment_methods'] as List?)
              ?.map((e) =>
                  PaymentMethodBreakdown.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      hourlyBreakdown: (json['hourly_breakdown'] as List?)
              ?.map(
                  (e) => HourlyBreakdown.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// Төлбөрийн хэлбэрийн задаргаа (бэлэн, карт гэх мэт)
class PaymentMethodBreakdown {
  final String method;
  final double amount;
  final int count;

  const PaymentMethodBreakdown({
    required this.method,
    required this.amount,
    required this.count,
  });

  factory PaymentMethodBreakdown.fromJson(Map<String, dynamic> json) {
    return PaymentMethodBreakdown(
      method: json['method'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      count: (json['count'] as num?)?.toInt() ?? 0,
    );
  }

  /// Төлбөрийн хэлбэрийн монгол нэр
  String get displayName {
    switch (method) {
      case 'cash':
        return 'Бэлэн';
      case 'card':
        return 'Карт';
      case 'bank':
        return 'Банк';
      case 'qpay':
        return 'QPay';
      default:
        return method;
    }
  }
}

/// Цаг тутмын задаргаа (0-23)
class HourlyBreakdown {
  final int hour;
  final double sales;
  final int count;

  const HourlyBreakdown({
    required this.hour,
    required this.sales,
    required this.count,
  });

  factory HourlyBreakdown.fromJson(Map<String, dynamic> json) {
    return HourlyBreakdown(
      hour: (json['hour'] as num?)?.toInt() ?? 0,
      sales: (json['sales'] as num?)?.toDouble() ?? 0,
      count: (json['count'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Шилдэг борлуулалттай бараа (Top Products report)
class TopProductReport {
  final String productId;
  final String productName;
  final String? productSku;
  final int totalQuantity;
  final double totalRevenue;
  final int salesCount;

  const TopProductReport({
    required this.productId,
    required this.productName,
    this.productSku,
    required this.totalQuantity,
    required this.totalRevenue,
    required this.salesCount,
  });

  factory TopProductReport.fromJson(Map<String, dynamic> json) {
    return TopProductReport(
      productId: json['product_id'] as String? ?? '',
      productName: json['product_name'] as String? ?? '',
      productSku: json['product_sku'] as String?,
      totalQuantity: (json['total_quantity'] as num?)?.toInt() ?? 0,
      totalRevenue: (json['total_revenue'] as num?)?.toDouble() ?? 0,
      salesCount: (json['sales_count'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Ашгийн тайлан
class ProfitReport {
  final double totalRevenue;
  final double totalCost;
  final double totalDiscount;
  final double grossProfit;
  final double profitMargin;
  final List<ProductProfit> byProduct;

  const ProfitReport({
    required this.totalRevenue,
    required this.totalCost,
    required this.totalDiscount,
    required this.grossProfit,
    required this.profitMargin,
    required this.byProduct,
  });

  factory ProfitReport.fromJson(Map<String, dynamic> json) {
    return ProfitReport(
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0,
      totalCost: (json['totalCost'] as num?)?.toDouble() ?? 0,
      totalDiscount: (json['totalDiscount'] as num?)?.toDouble() ?? 0,
      grossProfit: (json['grossProfit'] as num?)?.toDouble() ?? 0,
      profitMargin: (json['profitMargin'] as num?)?.toDouble() ?? 0,
      byProduct: (json['byProduct'] as List?)
              ?.map(
                  (e) => ProductProfit.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// Бараагаар задалсан ашиг
class ProductProfit {
  final String productId;
  final String name;
  final double revenue;
  final double cost;
  final double discount;
  final double profit;
  final double margin;
  final int quantity;

  const ProductProfit({
    required this.productId,
    required this.name,
    required this.revenue,
    required this.cost,
    required this.discount,
    required this.profit,
    required this.margin,
    required this.quantity,
  });

  factory ProductProfit.fromJson(Map<String, dynamic> json) {
    return ProductProfit(
      productId: json['product_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0,
      cost: (json['cost'] as num?)?.toDouble() ?? 0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0,
      profit: (json['profit'] as num?)?.toDouble() ?? 0,
      margin: (json['margin'] as num?)?.toDouble() ?? 0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Муу зарагддаг бараа (Slow-Moving Products)
class SlowMovingProduct {
  final String productId;
  final String name;
  final String? sku;
  final int stockQuantity;
  final int soldQuantity;
  final String? lastSoldAt;
  final double costValue;

  const SlowMovingProduct({
    required this.productId,
    required this.name,
    this.sku,
    required this.stockQuantity,
    required this.soldQuantity,
    this.lastSoldAt,
    required this.costValue,
  });

  factory SlowMovingProduct.fromJson(Map<String, dynamic> json) {
    return SlowMovingProduct(
      productId: json['product_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      sku: json['sku'] as String?,
      stockQuantity: (json['stock_quantity'] as num?)?.toInt() ?? 0,
      soldQuantity: (json['sold_quantity'] as num?)?.toInt() ?? 0,
      lastSoldAt: json['last_sold_at'] as String?,
      costValue: (json['cost_value'] as num?)?.toDouble() ?? 0,
    );
  }
}
