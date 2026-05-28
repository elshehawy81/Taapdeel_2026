class BillingData {
  String? email="Unknown@gmail.com";
  String? firstName ="Unknown name ";
  String? lastName="unknown feild";
  String? phoneNumber = "01011403690";
  String? apartment;
  String? building;
  String? postalCode;
  String? city;
  String? state;
  String? country = "Egypt";
  String? floor;
  String? street;
  String? shippingMethod;

  BillingData({
    this.email,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.apartment,
    this.building,
    this.postalCode,
    this.city,
    this.state,
    this.country,
    this.floor,
    this.street,
    this.shippingMethod,
  });

  Map<String, dynamic> toJson() {
    return<String, dynamic> {
      "email": email ?? "Unidentified",
      "first_name": firstName ?? "Unidentified",
      "last_name": lastName ?? "-",
      "phone_number": phoneNumber ?? "Unidentified",
      "apartment": apartment ?? "NA",
      "building": building ?? "NA",
      "street": street ?? "NA",
      "postal_code": postalCode ?? "NA",
      "city": city ?? "NA",
      "state": state ?? "NA",
      "country": country ?? "NA",
      "floor": floor ?? "NA",
      "shipping_method": shippingMethod ?? "NA",
    };
  }
}
