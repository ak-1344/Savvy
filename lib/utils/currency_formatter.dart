class CurrencyFormatter {
  static String format(double amount, String currency) {
    return '$currency ${amount.toStringAsFixed(2)}';
  }

  static String _getCurrencySymbol(String currency) {
    switch (currency) {
      case 'INR':
        return '₹';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      default:
        return currency;
    }
  }
}
