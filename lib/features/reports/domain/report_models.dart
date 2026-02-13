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

/// Категори аналитик тайлан — категори бүрийн борлуулалт, ашгийн задаргаа
class CategoryReport {
  final String category;
  final double totalRevenue;
  final int totalQuantity;
  final double totalCost;
  final double totalProfit;
  final double profitMargin;
  final int transactionCount;
  final int productCount;

  const CategoryReport({
    required this.category,
    required this.totalRevenue,
    required this.totalQuantity,
    required this.totalCost,
    required this.totalProfit,
    required this.profitMargin,
    required this.transactionCount,
    required this.productCount,
  });

  factory CategoryReport.fromJson(Map<String, dynamic> json) {
    return CategoryReport(
      category: json['category'] as String? ?? 'Бусад',
      totalRevenue: (json['total_revenue'] as num?)?.toDouble() ?? 0,
      totalQuantity: (json['total_quantity'] as num?)?.toInt() ?? 0,
      totalCost: (json['total_cost'] as num?)?.toDouble() ?? 0,
      totalProfit: (json['total_profit'] as num?)?.toDouble() ?? 0,
      profitMargin: (json['profit_margin'] as num?)?.toDouble() ?? 0,
      transactionCount: (json['transaction_count'] as num?)?.toInt() ?? 0,
      productCount: (json['product_count'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Сарын нэгдсэн тайлан — бүх KPI нэг дэлгэцэд
class MonthlyReport {
  final String month;
  final double totalRevenue;
  final double totalCost;
  final double totalProfit;
  final double profitMargin;
  final int totalTransactions;
  final int totalItemsSold;
  final double totalDiscount;
  // Өмнөх сартай харьцуулалт
  final MonthlyComparison previousMonth;
  final double revenueChangePercent;
  final double profitChangePercent;
  // Задаргаа
  final List<PaymentMethodBreakdown> paymentMethods;
  final List<MonthlyTopProduct> topProducts;
  final TransferSummary transfers;
  final List<SellerSummary> sellerSummary;

  const MonthlyReport({
    required this.month,
    required this.totalRevenue,
    required this.totalCost,
    required this.totalProfit,
    required this.profitMargin,
    required this.totalTransactions,
    required this.totalItemsSold,
    required this.totalDiscount,
    required this.previousMonth,
    required this.revenueChangePercent,
    required this.profitChangePercent,
    required this.paymentMethods,
    required this.topProducts,
    required this.transfers,
    required this.sellerSummary,
  });

  factory MonthlyReport.fromJson(Map<String, dynamic> json) {
    return MonthlyReport(
      month: json['month'] as String? ?? '',
      totalRevenue: (json['total_revenue'] as num?)?.toDouble() ?? 0,
      totalCost: (json['total_cost'] as num?)?.toDouble() ?? 0,
      totalProfit: (json['total_profit'] as num?)?.toDouble() ?? 0,
      profitMargin: (json['profit_margin'] as num?)?.toDouble() ?? 0,
      totalTransactions: (json['total_transactions'] as num?)?.toInt() ?? 0,
      totalItemsSold: (json['total_items_sold'] as num?)?.toInt() ?? 0,
      totalDiscount: (json['total_discount'] as num?)?.toDouble() ?? 0,
      previousMonth: MonthlyComparison.fromJson(
          json['previous_month'] as Map<String, dynamic>? ?? {}),
      revenueChangePercent:
          (json['revenue_change_percent'] as num?)?.toDouble() ?? 0,
      profitChangePercent:
          (json['profit_change_percent'] as num?)?.toDouble() ?? 0,
      paymentMethods: (json['payment_methods'] as List?)
              ?.map((e) =>
                  PaymentMethodBreakdown.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      topProducts: (json['top_products'] as List?)
              ?.map((e) =>
                  MonthlyTopProduct.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      transfers: TransferSummary.fromJson(
          json['transfers'] as Map<String, dynamic>? ?? {}),
      sellerSummary: (json['seller_summary'] as List?)
              ?.map(
                  (e) => SellerSummary.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// Өмнөх сарын харьцуулалтын мэдээлэл
class MonthlyComparison {
  final double totalRevenue;
  final double totalProfit;
  final int totalTransactions;

  const MonthlyComparison({
    required this.totalRevenue,
    required this.totalProfit,
    required this.totalTransactions,
  });

  factory MonthlyComparison.fromJson(Map<String, dynamic> json) {
    return MonthlyComparison(
      totalRevenue: (json['total_revenue'] as num?)?.toDouble() ?? 0,
      totalProfit: (json['total_profit'] as num?)?.toDouble() ?? 0,
      totalTransactions: (json['total_transactions'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Сарын шилдэг бараа
class MonthlyTopProduct {
  final String productId;
  final String productName;
  final int totalQuantity;
  final double totalRevenue;

  const MonthlyTopProduct({
    required this.productId,
    required this.productName,
    required this.totalQuantity,
    required this.totalRevenue,
  });

  factory MonthlyTopProduct.fromJson(Map<String, dynamic> json) {
    return MonthlyTopProduct(
      productId: json['product_id'] as String? ?? '',
      productName: json['product_name'] as String? ?? '',
      totalQuantity: (json['total_quantity'] as num?)?.toInt() ?? 0,
      totalRevenue: (json['total_revenue'] as num?)?.toDouble() ?? 0,
    );
  }
}

/// Шилжүүлгийн хураангуй
class TransferSummary {
  final int outgoingCount;
  final int incomingCount;
  final int outgoingItems;
  final int incomingItems;

  const TransferSummary({
    required this.outgoingCount,
    required this.incomingCount,
    required this.outgoingItems,
    required this.incomingItems,
  });

  factory TransferSummary.fromJson(Map<String, dynamic> json) {
    return TransferSummary(
      outgoingCount: (json['outgoing_count'] as num?)?.toInt() ?? 0,
      incomingCount: (json['incoming_count'] as num?)?.toInt() ?? 0,
      outgoingItems: (json['outgoing_items'] as num?)?.toInt() ?? 0,
      incomingItems: (json['incoming_items'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Худалдагчийн хураангуй (сарын тайланд)
class SellerSummary {
  final String sellerId;
  final String sellerName;
  final double totalSales;
  final int totalTransactions;

  const SellerSummary({
    required this.sellerId,
    required this.sellerName,
    required this.totalSales,
    required this.totalTransactions,
  });

  factory SellerSummary.fromJson(Map<String, dynamic> json) {
    return SellerSummary(
      sellerId: json['seller_id'] as String? ?? '',
      sellerName: json['seller_name'] as String? ?? '',
      totalSales: (json['total_sales'] as num?)?.toDouble() ?? 0,
      totalTransactions: (json['total_transactions'] as num?)?.toInt() ?? 0,
    );
  }
}
