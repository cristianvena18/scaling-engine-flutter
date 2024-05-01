import { Controller, Get, HttpCode, HttpStatus, Post } from '@nestjs/common';

import { AppService } from './app.service';
import { ErrorHandler } from '@pepa/sdui';

@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {
  }

  @Get('/')
  getData() {
    return this.appService.getData();
  }

  @Get('/chat')
  @HttpCode(HttpStatus.OK)
  getChat(): string {
    return `{
    "type": "Screen",
    "appBar": {
        "type": "AppBar",
        "attributes": {
            "title": "Profile"
        }
    },
    "child": {
        "type": "Form",
        "attributes": {
            "padding": 10
        },
        "children": [
            {
                "type": "Input",
                "attributes": {
                    "name": "first_name",
                    "value": "Ray",
                    "caption": "First Name",
                    "maxLength": 30
                }
            },
            {
                "type": "Input",
                "attributes": {
                    "name": "last_name",
                    "value": "Sponsible",
                    "caption": "Last Name",
                    "maxLength": 30
                }
            },
            {
                "type": "Input",
                "attributes": {
                    "name": "email",
                    "value": "ray.sponsible@gmail.com",
                    "caption": "Email *",
                    "required": true
                }
            },
            {
                "type": "Input",
                "attributes": {
                    "type": "date",
                    "name": "birth_date",
                    "caption": "Date of Birth"
                }
            },
            {
                "type": "Input",
                "attributes": {
                    "type": "Submit",
                    "name": "submit",
                    "caption": "Create Profile"
                },
                "action": {
                    "type": "Command",
                    "url": "http://${process.env.IP}/profile",
                    "prompt": {
                        "type": "Dialog",
                        "attributes": {
                            "type": "confirm",
                            "title": "Confirmation",
                            "message": "Are you sure you want to change your profile?"
                        }
                    }
                }
            }
        ]
    }
}`;
  }


  @Post('/profile')
  @HttpCode(HttpStatus.OK)
  profile() {
    return JSON.stringify({"type": 'route', "url": `http://${process.env.IP}/`, replacement: true});
  }

  @Get('error-view')
  error() {

    return ''
  }

  @Get('error-snackbar')
  errorSnackbar() {

    const errorView = ErrorHandler
      .builder()
      .snackbar('Debe completar todos los campos');

    return errorView.build();
  }
}
