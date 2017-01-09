// Copyright (c) 2017, Charlie Youakim. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.
import 'dart:html';
import 'address.dart';
import 'dart:convert';

void main() {
	Address myAddress;
	AddressEditor myAddressEditor;

  void initAddress() {
    myAddress = new Address(street : "10");
    myAddressEditor = new AddressEditor(myAddress);
    myAddressEditor.initHandlers();
    print("got message");
  }

  void getAddressUpdate() {
    String addressJSON = myAddressEditor.getAddressJSON();
    var response = {
      "type": "getAddressUpdateResponse",
      "data": JSON.encode(addressJSON)
    };
    var c = new CustomEvent("fromDart", detail: response);
    document.dispatchEvent(c);
  }

	document.on["fromJS"].listen((CustomEvent event) {
    var detail = event.detail;
    print(detail["command"]);
    switch (detail["command"]) {
      case 'initAddressEditor':
        initAddress();
        break;
      case 'getAddressUpdate':
        print('gettingAddressS');
        getAddressUpdate();
        break;
    }
	});

  //Tell JS we are loaded
  var c = new CustomEvent("fromDart", detail: {
      "type": "init"
  });
  document.dispatchEvent(c);

}
