___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


___INFO___

{
  "type": "TAG",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "Spotify CAPI 3P Integration Tag",
  "categories": [
        "CONVERSION",
        "ADVERTISING",
        "ANALYTICS"
        ],
  "brand": {
    "id": "brand_dummy",
    "displayName": ""
  },
  "description": "The server-side tag template to send event from your tagging server to Spotify Conversions API.",
  "containerContexts": [
    "SERVER"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "TEXT",
    "name": "authToken",
    "displayName": "Authentication Token",
    "simpleValueType": true,
    "help": "Necessary for authorizing the request to the Conversions API 3P handler",
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ]
  },
  {
    "type": "TEXT",
    "name": "connectionId",
    "displayName": "Connection ID",
    "simpleValueType": true
  },
  {
    "type": "TEXT",
    "name": "eventID",
    "displayName": "Event ID",
    "simpleValueType": true
  },
  {
    "type": "CHECKBOX",
    "name": "opt_out_targeting",
    "checkboxText": "Opt Out of Targeting",
    "simpleValueType": true
  },
  {
    "type": "SELECT",
    "name": "eventName",
    "displayName": "Event Name",
    "selectItems": [
      {
        "value": "ADD_CART",
        "displayValue": "ADD CART"
      },
      {
        "value": "START_CHECKOUT",
        "displayValue": "START CHECKOUT"
      },
      {
        "value": "LEAD",
        "displayValue": "LEAD"
      },
      {
        "value": "PAGE_VIEW",
        "displayValue": "PAGE VIEW"
      },
      {
        "value": "PURCHASE",
        "displayValue": "PURCHASE"
      },
      {
        "value": "SIGN_UP",
        "displayValue": "SIGN UP"
      },
      {
        "value": "VIEW_PRODUCT",
        "displayValue": "VIEW PRODUCT"
      },
      {
        "value": "CUSTOM_EVENT_1",
        "displayValue": "CUSTOM EVENT 1"
      },
      {
        "value": "CUSTOM_EVENT_2",
        "displayValue": "CUSTOM EVENT 2"
      },
      {
        "value": "CUSTOM_EVENT_3",
        "displayValue": "CUSTOM EVENT 3"
      },
      {
        "value": "CUSTOM_EVENT_4",
        "displayValue": "CUSTOM EVENT 4"
      },
      {
        "value": "CUSTOM_EVENT_5",
        "displayValue": "CUSTOM EVENT 5"
      }
    ],
    "simpleValueType": true
  },
  {
    "type": "RADIO",
    "name": "actionSource",
    "displayName": "Action Source",
    "radioItems": [
      {
        "value": "WEB",
        "displayValue": "Web"
      },
      {
        "value": "OFFLINE",
        "displayValue": "Offline"
      },
      {
        "value": "APP",
        "displayValue": "App"
      },
      {
        "value": "MOBILE",
        "displayValue": "Mobile"
      }
    ],
    "simpleValueType": true
  },
  {
    "type": "TEXT",
    "name": "contentCategory",
    "displayName": "Content Category - Category of the content",
    "simpleValueType": true
  },
  {
    "type": "TEXT",
    "name": "contentName",
    "displayName": "Content Name - Name of the product or page involved in the event",
    "simpleValueType": true
  }
]


___SANDBOXED_JS_FOR_SERVER___

// Sandbox Javascript API imports
const sendHttpRequest = require('sendHttpRequest');
const logToConsole = require('logToConsole');
const createRequestUrl = require('createRequestUrl');
const makeString = require('makeString');
const JSON = require('JSON');
const getTimestampMillis = require('getTimestampMillis');
const getAllEventData = require('getAllEventData');
const getRequestHeader = require('getRequestHeader');


// Dynamic variables
const eventData = getAllEventData();
const endpointUrl = data.apiEndpointUrl;
const conversion_events_builder = {};
const conversion_events_3P = {};

if(!data.connectionId || !data.authToken) {
  return data.gtmOnFailure();
}

// logic for building Conversion 3P event object
const conversion_event = mapEvent(eventData);

conversion_events_builder.events = [conversion_event];
conversion_events_builder.connectionId = data.connectionId;


conversion_events_3P.third_party_source = "google_tag_manager";
conversion_events_3P.conversion_events = conversion_events_builder;


// Preparing the HTTP POST call to CAPI endpoint
const postBody = JSON.stringify(conversion_events_3P);
const requestHeaders = {
  'Authorization': 'Bearer ' + data.authToken,
  'Content-Type': 'application/json'
  };


if (validateUserData()){
  sendConversionData();
} else {
  logToConsole('No conversion event was sent to CAPI. Please verify that user fields are provided');
  data.gtmOnFailure();
}


function validateUserData() {
  var data_is_valid_flag = true; 
  const userData = conversion_event.user_data;
  
  if(userData.hashed_emails.length === 0){
    logToConsole('INVALID DATA: Emails addresses were not provided');
    data_is_valid_flag = false;
  }
    
  if(userData.ip_address == null || userData.ip_address == "" ){
    logToConsole('INVALID DATA: IP addresses was not provided');
    data_is_valid_flag = false;
  }
  
  if(userData.hashed_phone_number == null || userData.hashed_phone_number == ""){
    logToConsole('INVALID DATA: Phone number was provided');
    data_is_valid_flag = false;
  } 
  
  if(userData.device_id == null || userData.device_id == ""){
    logToConsole('INVALID DATA: Device ID was not provided');
    data_is_valid_flag = false;
  } 
  
  if(userData.user_agent == null || userData.user_agent == "" ){
    logToConsole('INVALID DATA: user agent was not provided');
    data_is_valid_flag = false;
  } 
 
  return data_is_valid_flag;
}


function sendConversionData() {
  
  sendHttpRequest(endpointUrl, {
  headers: requestHeaders,
  method: 'POST',
  }, postBody)
    .then(response => {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      logToConsole('Event sent successfully.');
      data.gtmOnSuccess();
    } else{
      logToConsole('Failed to send event: ' + response.body);
      data.gtmOnFailure();
    } 
  }).catch(error => {
    logToConsole('Error sending event, caused by: ' + error.reason);
    data.gtmOnFailure();

  });
}

function mapEvent(eventData) {
  let mappedData = {};
  // may need logic to map the event name from eventData to valid event names
  mappedData.event_name = (data.eventName != null) ? data.eventName: eventData.event_name;
  
  mappedData.event_time = (eventData.event_time != null) ? eventData.event_time : getTimestampMillis();
  
  mappedData.action_source = data.actionSource || 'WEB';
  
  mappedData.opt_out_targeting = data.opt_out_targeting || false;
  
  mappedData.event_source_url = eventData.page_location || eventData.page_referrer || getRequestHeader('referer');
  
  mappedData.event_id = (data.eventID != null) ? data.eventID : ""; 

  mappedData = addUserData(eventData, mappedData);
  mappedData = addEventDetails(eventData, mappedData);
  
  return mappedData;
}

function addUserData(eventData, mappedData) {
  mappedData.user_data = {};

  // Pull user data if available 
  if (eventData.user_data != null){
    mappedData.user_data.hashed_emails = (eventData.user_data.sha256_email_address!= null) ? [eventData.user_data.sha256_email_address] : [];
    
    mappedData.user_data.ip_address = eventData.user_data.ip_override;
    
    mappedData.user_data.hashed_phone_number = eventData.user_data.sha256_phone_number;

    mappedData.user_data.device_id = (eventData.user_data.client_id != null) ? eventData.user_data.client_id :  "";
    
    mappedData.user_data.user_agent = eventData.user_data.user_agent;
  }
  
  return mappedData;
}

function addEventDetails(eventData, mappedData) {
  mappedData.event_details = {};

  //assuming we have currency and value being sent, but this isnt guaranteed 
  mappedData.event_details.amount = eventData.value || eventData.price;
  
  mappedData.event_details.currency = (eventData.currency != null) ? eventData.currency : "";
  
  mappedData.content_name = (data.contentCategory != null) ? data.contentCategory : "";
  
  mappedData.content_category = (data.contentName != null) ? data.contentName : ""; 
  
  return mappedData;

}


___SERVER_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "logging",
        "versionId": "1"
      },
      "param": [
        {
          "key": "environments",
          "value": {
            "type": 1,
            "string": "debug"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "send_http",
        "versionId": "1"
      },
      "param": [
        {
          "key": "allowedUrls",
          "value": {
            "type": 1,
            "string": "any"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "read_event_data",
        "versionId": "1"
      },
      "param": [
        {
          "key": "eventDataAccess",
          "value": {
            "type": 1,
            "string": "any"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "read_request",
        "versionId": "1"
      },
      "param": [
        {
          "key": "headerWhitelist",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "headerName"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "referer"
                  }
                ]
              }
            ]
          }
        },
        {
          "key": "headersAllowed",
          "value": {
            "type": 8,
            "boolean": true
          }
        },
        {
          "key": "requestAccess",
          "value": {
            "type": 1,
            "string": "specific"
          }
        },
        {
          "key": "headerAccess",
          "value": {
            "type": 1,
            "string": "specific"
          }
        },
        {
          "key": "queryParameterAccess",
          "value": {
            "type": 1,
            "string": "any"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  }
]


___TESTS___

scenarios: []


___NOTES___

Created on 10/1/2024, 4:32:28 PM


