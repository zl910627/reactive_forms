/// This class is an utility for getting access to common names of
/// validation messages.
///
/// ## Example
///
/// ```dart
/// ReactiveTextField(
///   formControlName: 'email',
///   validationMessages: {
///     ValidationMessage.required: 'The Email must not be empty',
///     ValidationMessage.email: 'The Email must be a valid email'
///   },
/// );
/// ```
class ValidationMessage {
  /// Key text for required validation message.
  static const String required = 'required';

  /// Key text for pattern validation message.
  static const String pattern = 'pattern';

  /// Key text for number validation message.
  static const String number = 'number';

  /// Key text for must match validation message.
  static const String mustMatch = 'mustMatch';

  /// Key text for min length validation message.
  static const String minLength = 'minLength';

  /// Key text for max length validation message.
  static const String maxLength = 'maxLength';

  /// Key text for email validation message.
  static const String email = 'email';

  /// Key text for credit card numbers validation message.
  static const String creditCard = 'creditCard';
}
