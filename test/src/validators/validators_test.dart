import 'package:flutter_test/flutter_test.dart';
import 'package:reactive_forms/reactive_forms.dart';

void main() {
  group('Email Validator Tests', () {
    test('FormControl valid with null email', () {
      final control = FormControl(validators: [Validators.email]);

      expect(control.valid, true);
    });

    test('FormControl invalid with invalid email', () {
      final control = FormControl(validators: [Validators.email]);

      control.value = 'johndoe@email';

      expect(control.invalid, true);
    });

    test('FormControl valid with valid email', () {
      final control = FormControl(validators: [Validators.email]);

      control.value = 'johndoe@email.com';

      expect(control.valid, true);
    });

    test('FormControl invalid with not String email', () {
      final control = FormControl(validators: [Validators.email]);

      control.value = 123;

      expect(control.invalid, true);
    });
  });

  group('MinLength Validator Tests', () {
    test('FormControl invalid if minLength invalid', () {
      final control = FormControl(
        defaultValue: 'Hello',
        validators: [Validators.minLength(6)],
      );

      expect(control.invalid, true);
      expect(control.errors[ValidationMessage.minLength] != null, true);
    });
  });

  group('MaxLength Validator Tests', () {
    test('FormControl invalid if maxLength invalid', () {
      final control = FormControl(
        defaultValue: 'Hello Reactive Forms',
        validators: [Validators.maxLength(10)],
      );

      expect(control.invalid, true);
      expect(control.errors[ValidationMessage.maxLength] != null, true);
    });
  });

  group('MustMatch Validator Tests', () {
    test('FormGroup invalid if passwords mismatch', () {
      final form = FormGroup({
        'password': FormControl(defaultValue: '1234'),
        'passwordConfirmation': FormControl(defaultValue: '123'),
      }, validators: [
        Validators.mustMatch('password', 'passwordConfirmation'),
      ]);

      expect(form.invalid, true);
      expect(
        form.errors['passwordConfirmation'][ValidationMessage.mustMatch],
        true,
      );
    });

    test('FormGroup valid if passwords match', () {
      final form = FormGroup({
        'password': FormControl(defaultValue: '1234'),
        'passwordConfirmation': FormControl(defaultValue: '123'),
      }, validators: [
        Validators.mustMatch('password', 'passwordConfirmation'),
      ]);

      final passwordConfirmation = form.control('passwordConfirmation');
      passwordConfirmation.value = '1234';

      expect(form.valid, true);
      expect(form.hasErrors, false);
    });
  });

  group('Pattern Validator Tests', () {
    test('FormControl invalid if value not matched pattern', () {
      const AmericanExpressPattern = r'^3[47][0-9]{13}$';

      final cardNumber = FormControl(
        validators: [Validators.pattern(AmericanExpressPattern)],
      );

      cardNumber.value = '395465465421'; // not a valid number

      expect(cardNumber.valid, false);
      expect(cardNumber.errors.containsKey(ValidationMessage.pattern), true);
    });

    test('FormControl valid if value matched pattern', () {
      const AmericanExpressPattern = r'^3[47][0-9]{13}$';

      final cardNumber = FormControl(
        validators: [Validators.pattern(AmericanExpressPattern)],
      );

      cardNumber.value = '342654321654213';

      expect(cardNumber.valid, true);
      expect(cardNumber.errors.keys.isEmpty, true);
    });
  });

  group('Number Validator Tests', () {
    test('FormControl invalid if not a number', () {
      final control = FormControl<String>(validators: [Validators.number]);

      control.value = 'hello';

      expect(control.valid, false);
      expect(control.errors.containsKey(ValidationMessage.number), true);
    });

    test('FormControl valid if a number', () {
      final control = FormControl<String>(validators: [Validators.number]);

      control.value = '10';

      expect(control.valid, true);
    });
  });

  group('Composing Validator Tests', () {
    test(
      'If none validators validate to VALID then the control is INVALID',
      () {
        // Given: a control that is email and min length in 20
        final control = FormControl<String>(
          defaultValue: 'john@',
          validators: Validators.compose([
            Validators.email,
            Validators.minLength(20),
          ]),
        );

        // Expect: control invalid
        expect(control.valid, false);
      },
    );

    test(
      'If none validators validate to VALID then the control is INVALID',
      () {
        // Given: a control that is email and min length in 20
        // but with valid email default value
        final control = FormControl<String>(
          defaultValue: 'john@email.com',
          validators: Validators.compose([
            Validators.email,
            Validators.minLength(20),
          ]),
        );

        // Expect: control invalid
        expect(control.valid, true);
      },
    );
  });

  group('Credit Card Validator Tests', () {
    test('Test card number with empty white spaces is valid', () {
      // Given: a credit card number
      final control = FormControl<String>(
        defaultValue: '5500 0000 0000 0004',
        validators: [Validators.creditCard],
      );

      // Expect: number is valid
      expect(control.valid, true);
    });

    test('Validates a valid credit card number', () {
      // Given: a credit card number
      final control = FormControl<String>(
        defaultValue: '5555555555554444',
        validators: [Validators.creditCard],
      );

      // Expect: number is valid
      expect(control.valid, true);
    });

    test('Validates an invalid credit card number', () {
      // Given: a credit card number
      final control = FormControl<String>(
        defaultValue: '7992739871',
        validators: [Validators.creditCard],
      );

      // Expect: number is not valid
      expect(control.valid, false);
    });

    test('Validates invalid number string', () {
      // Given: an invalid credit card number
      final control = FormControl<String>(
        defaultValue: '5500abc000000004',
        validators: [Validators.creditCard],
      );

      // Expect: number is not valid
      expect(control.valid, false);
    });

    test('Validates that card number must not bee empty', () {
      // Given: an invalid credit card number
      final control = FormControl<String>(
        defaultValue: '',
        validators: [Validators.creditCard],
      );

      // Expect: number is not valid
      expect(control.valid, false);
    });

    test('Validates a card number with length lower than 13 is invalid', () {
      // Given: an invalid credit card number
      final control = FormControl<String>(
        defaultValue: '123456789123',
        validators: [Validators.creditCard],
      );

      // Expect: number is not valid
      expect(control.valid, false);
    });

    test('Validates a card number exceed 19 numbers is invalid', () {
      // Given: an invalid credit card number
      final control = FormControl<String>(
        defaultValue: '12345678912345678909',
        validators: [Validators.creditCard],
      );

      // Expect: number is not valid
      expect(control.valid, false);
    });

    test('Test some valid credit cards', () {
      // Given: an invalid credit card number
      final cardNumbers = [
        '4111 1111 1111 1111',
        '5500 0000 0000 0004',
        '3400 0000 0000 009',
        '3000 0000 0000 04',
        '6011 0000 0000 0004',
        '2014 0000 0000 009',
        '3088 0000 0000 0009',
      ];

      final control = FormControl<String>(
        validators: [Validators.creditCard],
      );

      cardNumbers.forEach((cardNumber) {
        control.value = cardNumber;
        expect(control.valid, true, reason: '[$cardNumber] is not valid');
      });
    });
  });
}
