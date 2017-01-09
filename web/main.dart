// Copyright (c) 2017, Charlie Youakim. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:html';
import 'address/address.dart';

void main() {
  querySelector('#output').text = 'Your Dart app is running3.';
	Address myAddress = new Address(street: "10");
	AddressEditor myAddressEditor = new AddressEditor(myAddress);
	myAddressEditor.initHandlers();
}
