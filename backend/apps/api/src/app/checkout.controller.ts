import { Body, Controller, Get, HttpCode, HttpStatus, Post, Query } from '@nestjs/common';
import { Form, Input, Screen } from '@pepa/sdui';
import { Cta, Route } from '../../../../libs/sdui/src/actions';
import { Dialog } from '../../../../libs/sdui/src/components/dialog';

@Controller({ path: '/checkout' })
export class CheckoutController {

  @Get('/')
  startCheckout() {
    const screen = Screen.builder().children(
      Form.builder()
        .addInput(
          Input.builder()
            .type('number')
            .name('amount')
            .required()
            .placeholder('Ingresá tu monto')
        ).cta(
        Cta.builder().request(`http://${process.env.IP}/checkout/payment-methods`, 'Continuar')
      )
    );

    return JSON.stringify(screen.build());
  }

  @Post('/payment-methods')
  @HttpCode(HttpStatus.OK)
  checkout(@Body() data: any) {
    console.log('data received', data);

    const route = Route.builder().url(`http://${process.env.IP}/checkout/payment-methods`).parameters({ amount: data.amount });

    return JSON.stringify(route.build());
  }

  @Get('/payment-methods')
  paymentMethods(@Query() query: any) {

    console.log('query', query);

    const screen = Screen.builder().children(
      Form.builder()
        .addInput(
          Input.builder()
            .name('payment-method')
            .type('text')
            .placeholder('Metodo de pago')
        )
        .cta(
          Cta.builder()
            .prompt(
              Dialog.builder()
                .type('confirm')
                .title('Seguro?')
                .message('Seguro que quiere continuar?')
            )
            .request(`http://${process.env.IP}/checkout/process`, 'Elegir')
        )
    );

    return JSON.stringify(screen.build());
  }

  @Post('/process')
  @HttpCode(HttpStatus.OK)
  process(@Body() data: any) {
    console.log('data received', data);

    const route = Route.builder().url(`http://${process.env.IP}/checkout`).replacement().trackEvent("checkout-finished", 'checkout');

    return JSON.stringify(route.build());
  }
}
