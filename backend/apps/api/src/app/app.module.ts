import { Module } from '@nestjs/common';

import { AppController } from './app.controller';
import { AppService } from './app.service';
import { CheckoutController } from './checkout.controller';

@Module({
  imports: [],
  controllers: [AppController, CheckoutController],
  providers: [AppService],
})
export class AppModule {}
