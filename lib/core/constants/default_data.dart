import 'package:khatabook/core/enums/account_type.dart';

/// Default data for initial app setup.
///
/// These values are used to pre-populate the database on first launch.
/// The user can modify all of these after setup.
class DefaultData {
  DefaultData._();

  /// Default financial accounts created on first launch.
  static List<Map<String, dynamic>> defaultAccounts() {
    return [
      {
        'name': 'SCB Debit',
        'type': AccountType.debit,
        'iconName': 'account_balance',
        'colorValue': 0xFF1E88E5, // Blue
        'sortOrder': 0,
      },
      {
        'name': 'UCB Debit',
        'type': AccountType.debit,
        'iconName': 'account_balance',
        'colorValue': 0xFF43A047, // Green
        'sortOrder': 1,
      },
      {
        'name': 'City Debit',
        'type': AccountType.debit,
        'iconName': 'account_balance',
        'colorValue': 0xFF5E35B1, // Deep Purple
        'sortOrder': 2,
      },
      {
        'name': 'SCB Credit',
        'type': AccountType.credit,
        'iconName': 'credit_card',
        'colorValue': 0xFFE53935, // Red
        'sortOrder': 3,
      },
      {
        'name': 'UCB Credit',
        'type': AccountType.credit,
        'iconName': 'credit_card',
        'colorValue': 0xFFFF6F00, // Amber
        'sortOrder': 4,
      },
      {
        'name': 'Cash',
        'type': AccountType.cash,
        'iconName': 'payments',
        'colorValue': 0xFF2ECC71, // Emerald
        'sortOrder': 5,
      },
      {
        'name': 'Savings',
        'type': AccountType.savings,
        'iconName': 'savings',
        'colorValue': 0xFF00ACC1, // Cyan
        'sortOrder': 6,
      },
    ];
  }

  /// Default expense/income categories created on first launch.
  static List<Map<String, dynamic>> defaultCategories() {
    return [
      {
        'name': 'Food',
        'iconName': 'restaurant',
        'colorValue': 0xFFFF7043,
        'sortOrder': 0,
      },
      {
        'name': 'Clothing',
        'iconName': 'checkroom',
        'colorValue': 0xFFAB47BC,
        'sortOrder': 1,
      },
      {
        'name': 'Rent',
        'iconName': 'home',
        'colorValue': 0xFF42A5F5,
        'sortOrder': 2,
      },
      {
        'name': 'Gas',
        'iconName': 'local_gas_station',
        'colorValue': 0xFFEF5350,
        'sortOrder': 3,
      },
      {
        'name': 'Motorcycle',
        'iconName': 'two_wheeler',
        'colorValue': 0xFF66BB6A,
        'sortOrder': 4,
      },
      {
        'name': 'Baby',
        'iconName': 'child_care',
        'colorValue': 0xFFEC407A,
        'sortOrder': 5,
      },
      {
        'name': 'Transport',
        'iconName': 'directions_bus',
        'colorValue': 0xFF26A69A,
        'sortOrder': 6,
      },
      {
        'name': 'Gifts',
        'iconName': 'card_giftcard',
        'colorValue': 0xFFFFCA28,
        'sortOrder': 7,
      },
      {
        'name': 'Hobby',
        'iconName': 'sports_esports',
        'colorValue': 0xFF7E57C2,
        'sortOrder': 8,
      },
      {
        'name': 'Cigarettes',
        'iconName': 'smoking_rooms',
        'colorValue': 0xFF8D6E63,
        'sortOrder': 9,
      },
      {
        'name': 'Salary',
        'iconName': 'work',
        'colorValue': 0xFF4CAF50,
        'sortOrder': 10,
      },
      {
        'name': 'Other',
        'iconName': 'more_horiz',
        'colorValue': 0xFF78909C,
        'sortOrder': 11,
      },
    ];
  }

  /// Map icon name strings to Material icon code points.
  /// Used to resolve string-based icon references to actual icons.
  static const Map<String, int> iconCodePoints = {
    'account_balance': 0xe84f,
    'credit_card': 0xe870,
    'payments': 0xef63,
    'savings': 0xf0bc,
    'restaurant': 0xe56c,
    'checkroom': 0xf19b,
    'home': 0xe88a,
    'local_gas_station': 0xe546,
    'two_wheeler': 0xe9f9,
    'child_care': 0xeb41,
    'directions_bus': 0xe530,
    'card_giftcard': 0xe8f6,
    'sports_esports': 0xea28,
    'smoking_rooms': 0xeb4a,
    'work': 0xe8f9,
    'more_horiz': 0xe5d3,
    'shopping_cart': 0xe8cc,
    'local_hospital': 0xe548,
    'school': 0xe80c,
    'flight': 0xe539,
    'phone': 0xe0cd,
    'wifi': 0xe63e,
    'fitness_center': 0xeb43,
    'pets': 0xea91,
    'attach_money': 0xe227,
    'trending_up': 0xe8e5,
    'trending_down': 0xe8e3,
  };
}
