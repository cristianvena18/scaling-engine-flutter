import { Injectable } from '@nestjs/common';

@Injectable()
export class AppService {
  getData(): string {
    return `{
  "type": "Screen",
  "appBar": {
    "type": "AppBar",
    "attributes": {
      "title": "Home",
      "actions":[
        {
          "type": "Container",
          "attributes": {
            "padding": 10.0
          },
          "children":[
            {
              "type": "Icon",
              "attributes":{
                "code": "f27b"
              }
            }
          ],
          "action":{
            "type": "Route",
            "url": "http://${process.env.IP}/static",
            "trackEvent": "event01"
          }
        }
      ]
    }
  },
  "bottomNavigationBar": {
    "type": "BottomNavigationBar",
    "attributes":{
      "background": "#1D7EDF",
      "selectedItemColor": "#ffffff",
      "unselectedItemColor": "#ffffff"
    },
    "children":[
      {
        "type": "BottomNavigationBarItem",
        "attributes": {
          "icon": "f107",
          "caption": "Home"
        },
        "action":{
          "type": "Route",
          "url": "http://${process.env.IP}/static",
          "trackEvent": "event-home"
        }
      },
      {
        "type": "BottomNavigationBarItem",
        "attributes": {
          "icon": "f27b",
          "caption": "Me"
        },
        "action":{
          "type": "Route",
          "url": "http://${process.env.IP}/me"
        }
      },
      {
        "type": "BottomNavigationBarItem",
        "attributes": {
          "icon": "e211",
          "caption": "Remote"
        },
        "action":{
          "type": "Route",
          "url": "http://${process.env.IP}/remote"
        }
      },
      {
        "type": "BottomNavigationBarItem",
        "attributes": {
          "icon": "ef42",
          "caption": "Chat"
        },
        "action":{
          "type": "Route",
          "url": "http://${process.env.IP}/chat"
        }
      }
    ]
  },
  "child": {
    "type": "Center",
    "children": [
      {
        "type": "Input",
        "attributes": {
          "caption": "Sample Project",
          "padding": 5.0,
          "margin": 5.0
        }
      }
    ]
  },
  "attributes":{
    "id": "page.home"
  }
}`;
  }
}
