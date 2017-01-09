@JS('address')
library address;

import 'dart:html';
import 'package:dartson/dartson.dart';
import "package:js/js.dart";

var statesList = const [
'AL', 'AK', 'AZ', 'AR', 'CA', 'CO', 'CT', 'DC', 'DE', 'FL', 'GA',
'HI', 'ID', 'IL', 'IN', 'IA', 'KS', 'KY', 'LA', 'ME', 'MD',
'MA', 'MI', 'MN', 'MS', 'MO', 'MT', 'NE', 'NV', 'NH', 'NJ',
'NM', 'NY', 'NC', 'ND', 'OH', 'OK', 'OR', 'PA', 'RI', 'SC',
'SD', 'TN', 'TX', 'UT', 'VT', 'VA', 'WA', 'WV', 'WI', 'WY',
];

Dartson dson = new Dartson.JSON();

@Entity()
class AddressSuggestion{
	String PlaceID;
	String Description;
}

@Entity()
class Address{
	String google_place_id = '';
	String formatted_address = '';
	String street = '';
	String street2 = '';
	String city = '';
	String state = '';
	String postal_code = '';
	String country_code = '';
	double lat = 0.0;
	double lng = 0.0;

	Address({String street, String street2, String city, String state, String postal_code}) {
		this.street = street;
		this.street2 = street2;
		this.city = city;
		this.state = state;
		this.postal_code = postal_code;
	}
}

@JS("AddressEditor")
class AddressEditor {
	Address addressObj;
	DivElement anchorElement;
	InputElement addressStreetInput;
  DivElement addressSuggestions;
  InputElement addressStreet2Input;
  InputElement addressCityInput;
  SelectElement addressStateSelect;
  InputElement addressPostalCodeInput;

	AddressEditor(Address initialAddress) {
		this.addressObj = initialAddress;
	}

	void initHandlers() {
		anchorElement = document.querySelector('#anchor');
		_addAddressForm(anchorElement);
		addressStreetInput.addEventListener('keyup', (event) => _getAddressSuggestions());
		addressSuggestions.addEventListener('click', (event) => _suggestionClicked(event));
		addressStreet2Input.addEventListener('keyup', (event) => _populateObject());
		addressCityInput.addEventListener('keyup', (event) => _populateObject());
		addressStateSelect.addEventListener('change', (event) => _populateObject());
		addressPostalCodeInput.addEventListener('keyup', (event) => _populateObject());
	}

	void _getAddressSuggestions() {
		String newAddress = addressStreetInput.value;
		if(newAddress.length == 0){ // If input empty, erase suggestions
			addressSuggestions.setInnerHtml("");
		}else if(newAddress.length % 3 == 0 && newAddress.length != 0){ // Every three characters
			var requesturl = 'http://localhost:9090/v1/address/address_street?address_street=' + newAddress;

			void onDataLoaded(HttpRequest req)  {
				if (req.status >= 200 && req.status < 400) {
					List<AddressSuggestion> suggestionItems = dson.decode(req.responseText, new AddressSuggestion(), true);
					print(suggestionItems);
					addressSuggestions.setInnerHtml("");
					for (AddressSuggestion suggestionItem in suggestionItems){ // limit to three suggestions
						DivElement newSuggestion = new DivElement();
						newSuggestion.setAttribute("class", suggestionItem.PlaceID);
						newSuggestion.setInnerHtml(suggestionItem.Description);
						addressSuggestions.append(newSuggestion);
					}
				} else {
					print(req.status);
				}
			};

			void onRequestErred(HttpRequest req) {
				print("Error verifying address");
			};

			HttpRequest.request(requesturl).then(onDataLoaded, onError: onRequestErred);

		}
	}


	void _suggestionClicked(e) {
		addressSuggestions.setInnerHtml("");

		var zipurl = 'http://localhost:9090/v1/address/postal_code?place_id=' + e.target.className;

		void onDataLoaded(HttpRequest req)  {
			if (req.status >= 200 && req.status < 400) {
				addressObj = dson.decode(req.responseText, new Address());
				_populateForm();
			} else {
				print(req.status);
			}
		};

		void onRequestErred(HttpRequest req) {
			print("Error on zip request");
		};

		HttpRequest.request(zipurl).then(onDataLoaded, onError: onRequestErred);

	}

	void _populateForm() {
		addressStreetInput.value = addressObj.street;
		addressStreet2Input.value = addressObj.street2;
		addressCityInput.value = addressObj.city;
		addressStateSelect.value = addressObj.state;
		addressPostalCodeInput.value = addressObj.postal_code;
	}

	void _populateObject() {
		addressObj.street = addressStreetInput.value;
		addressObj.street2 = addressStreet2Input.value;
		addressObj.city = addressCityInput.value;
		addressObj.state = addressStateSelect.value;
		addressObj.postal_code = addressPostalCodeInput.value;
		print("addressObj = " + addressObj.toString());
	}

	void _addAddressForm(DivElement parent) {
		//Create the form piece by piece in code - better for the long term!
		//1st Input group - street
		DivElement address1stGroup = _createGroupDiv();
		DivElement addressStreetItem = _createItemDiv("{{flexGrow: 100}}");
		address1stGroup.append(addressStreetItem);
		LabelElement addressStreetLabel = _createLabelElement("Billing Address");
		addressStreetItem.append(addressStreetLabel);
		addressStreetInput = _createTextInput("sezzleaddrstreet", addressObj.street);
		addressStreetItem.append(addressStreetInput);
		addressSuggestions = new DivElement();
		addressSuggestions.setAttribute("id", "address-suggestions");
		addressStreetItem.append(addressSuggestions);
		//2nd Input group - street2, city, state, postalcode
		DivElement address2ndGroup = _createGroupDiv();
		//street2
		DivElement addressStreet2Item = _createItemDiv("{{flexBasis: '100px', flexGrow: 2, flexShrink: 0}}");
		address2ndGroup.append(addressStreet2Item);
		LabelElement addressStreet2Label = _createLabelElement("Suite");
		addressStreet2Item.append(addressStreet2Label);
		addressStreet2Input = _createTextInput("address_street2", addressObj.street2);
		addressStreet2Item.append(addressStreet2Input);
		//city
		DivElement addressCityItem = _createItemDiv("{{flexGrow: 40}}");
		address2ndGroup.append(addressCityItem);
		LabelElement addressCityLabel = _createLabelElement("City");
		addressCityItem.append(addressCityLabel);
		addressCityInput = _createTextInput("city", addressObj.city);
		addressCityItem.append(addressCityInput);
		//state
		DivElement addressStateItem = _createItemDiv("{{flexGrow: 10}}");
		address2ndGroup.append(addressStateItem);
		LabelElement addressStateLabel = _createLabelElement("State");
		addressStateItem.append(addressStateLabel);
		addressStateSelect = new SelectElement();
		addressStateSelect.setAttribute("id", "state");
		addressStateSelect.setAttribute("name", "state");
		//add the states to the select
		OptionElement nullChoice = new OptionElement(data: "---", value: "---", selected: true);
		addressStateSelect.append(nullChoice);
		for (var i = 0; i < statesList.length; i++) {
			//Add the item to the options
			OptionElement optionItem = new OptionElement(data: statesList[i], value: statesList[i]);
			addressStateSelect.append(optionItem);
		}
		addressStateItem.append(addressStateSelect);
		//postal code
		DivElement addressPostalCodeItem = _createItemDiv("{{flexGrow: 10}}");
		address2ndGroup.append(addressPostalCodeItem);
		LabelElement addressPostalCodeLabel = _createLabelElement("Zip Code");
		addressPostalCodeItem.append(addressPostalCodeLabel);
		addressPostalCodeInput = _createTextInput("postal_code", addressObj.postal_code);
		addressPostalCodeItem.append(addressPostalCodeInput);

		parent.append(address1stGroup);
		parent.append(address2ndGroup);
	}

	DivElement _createGroupDiv() {
		DivElement group = new DivElement();
		group.setAttribute("role", "group");
		return group;
	}

	DivElement _createItemDiv(String style) {
		DivElement item = new DivElement();
		item.setAttribute("role", "item");
		item.setAttribute("style", style);
		return item;
	}

	InputElement _createTextInput(String id, String initialValue) {
		InputElement input = new InputElement();
		input.setAttribute("type", "text");
		input.setAttribute("id", id);
		input.setAttribute("name", id); //just copying what was done
		input.value = initialValue;
		return input;
	}

	SpanElement _createItemError() {
		SpanElement itemError = new SpanElement();
		itemError.setAttribute("className", "item-error");
		return itemError;
	}

	LabelElement _createLabelElement(String label) {
		LabelElement addressStreetLabel = new LabelElement();
		addressStreetLabel.setInnerHtml(label);
		return addressStreetLabel;
	}

}
