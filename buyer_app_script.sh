function onFormSubmit(e) {
  var sheet = SpreadsheetApp.openById("1klI0LbiEyYm7NhMBsIaV3at_ntu1bOetCg92nJuUUHo").getSheetByName("Form Responses 1");
  var lastRow = sheet.getLastRow();
  var data = sheet.getRange(lastRow, 1, 1, sheet.getLastColumn()).getValues()[0];

  var date = data[1];
  var buyerName = data[2];
  var phone = data[3];
  var address = data[4];
  var sale_person_name = data[26];
  var sale_person_phone = data[27];
  var sale_person_address = data[28];
  var residential_building = data[5];
  var commercial_building = data[6];
  var preferred_township_location = data[7];
  var budget_from = data[8];
  var budget_to = data[9];
  var reason_for_purchase = data[10];
  var land_type = data[11];
  var land_ownership = data[12];
  var house_land_facing_direction = data[13];
  var land_area = data[14];
  var house_rooms = data[15];
  var house_toilets = data[16];
  var house_others = data[17];
  var squre_feet_area = data[18];
  var floor = data[19];
  var condo_apartment_facing_direction = data[20];
  var condo_apartment_rooms = data[21];
  var condo_apartment_toilets = data[22];
  var facilities = data[23];
  var condo_apartment_others = data[24];
  var buyer_requirements_detail = data[25];

  var odooUrl = "https://techkhit-test-crm.odoo.com";
  var db = "techkhit-test-crm";
  var userId = 2;
  var username = "dev.techkhit@gmail.com";
  var apiKey = "29086e9dee860142766dbfc3d89556f029ffd6a4";

  // --- Create Lead ---
  var createPayload = {
    "jsonrpc": "2.0",
    "method": "call",
    "params": {
      "service": "object",
      "method": "execute_kw",
      "args": [
        db, userId, apiKey,
        "crm.lead", "create",
        [{
          "name": buyerName + "'s Opportunity",
          "contact_name": buyerName,
          "street": address,
          "phone": phone,
          "team_id": 5
        }]
      ]
    }
  };

  var options = {
    "method": "post",
    "contentType": "application/json",
    "payload": JSON.stringify(createPayload),
    "headers": {
      "Authorization": "Basic " + Utilities.base64Encode(username + ":" + apiKey)
    }
  };

  var response = UrlFetchApp.fetch(odooUrl + "/jsonrpc", options);
  var result = JSON.parse(response.getContentText());
  var newLeadId = result.result;  // Odoo lead ID
  Logger.log("Created Lead ID: " + newLeadId);

  // --- Build Reference from ID ---
  var reference = "RF" + newLeadId.toString().padStart(9, "0");  // e.g., RF000000006
  Logger.log("Reference: " + reference);

  // --- Update Lead with Description including Reference ---
  var description = 
    "Admin Portal reference: " + reference + "<br>" +
    "Reference: " + reference + "<br>" +
    "Date: " + date + "<br>" +
    "ဝယ်သူ၏ အချက်အလက်. " + "<br>" +
    "Name: " + buyerName + "<br>" +
    "Phone: " + phone + "<br>" +
    "Address: " + address + "<br>" +
    "အရောင်း၀န်ထမ်းအချက်အလက်. " + "<br>" +
    "Name: " + sale_person_name + "<br>" +
    "Phone: " + sale_person_phone + "<br>" +
    "Address: " + sale_person_address + "<br>" +
    "Residential Building: " + residential_building + "<br>" +
    "Commercial Building: " + commercial_building + "<br>" +
    "Preferred Township/Location: " + preferred_township_location + "<br>" +
    "Allocated Budget for Purchase. " + "<br>" +
    "Budget From: " + budget_from + "<br>" +
    "Budget To: " + budget_to + "<br>" +
    "Reason for Purchase: " + reason_for_purchase + "<br>" +
    "Specific Purchase Requirements. " + "<br>" +
    "Land/House/Building and Other. " + "<br>" +
    "Land Type: " + land_type + "<br>" +
    "Land Ownership: " + land_ownership + "<br>" +
    "Facing Direction: " + house_land_facing_direction + "<br>" +
    "Land Area: " + land_area + "<br>" +
    "Rooms: " + house_rooms + "<br>" +
    "Bathrooms/Toilets: " + house_toilets + "<br>" +
    "Others: " + house_others + "<br>" +
    "Condo/Mini-condo/Apartment and Other. " + "<br>" +
    "Square Feet Area: " + squre_feet_area + "<br>" +
    "Floor: " + floor + "<br>" +
    "Facing: " + condo_apartment_facing_direction + "<br>" +
    "Rooms: " + condo_apartment_rooms + "<br>" +
    "Toilets: " + condo_apartment_toilets + "<br>" +
    "Facilities: " + facilities + "<br>" +
    "Others: " + condo_apartment_others + "<br>" +
    "Buyer Requirements: " + buyer_requirements_detail + "<br>";

  var updatePayload = {
    "jsonrpc": "2.0",
    "method": "call",
    "params": {
      "service": "object",
      "method": "execute_kw",
      "args": [
        db, userId, apiKey,
        "crm.lead", "write",
        [[newLeadId], {"description": description}]
      ]
    }
  };

  var updateResponse = UrlFetchApp.fetch(odooUrl + "/jsonrpc", {
    "method": "post",
    "contentType": "application/json",
    "payload": JSON.stringify(updatePayload),
    "headers": {
      "Authorization": "Basic " + Utilities.base64Encode(username + ":" + apiKey)
    }
  });

  Logger.log("Update Response: " + updateResponse.getContentText());
}