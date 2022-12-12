class User {
  String? id;
  String? firstname;
  String? lastname;
  String? email;
  String? mobile;
  String? dob='';
  String? bloodType='';
  String? height='';
  String? weight='';
  String? allergies='';
  String? registered;
  String? registrationStatus;
  String? image='';

  User(
      {this.id,
        this.firstname,
        this.lastname,
        this.email,
        this.mobile,
        this.dob,
        this.bloodType,
        this.height,
        this.weight,
        this.allergies,
        this.registered,
        this.registrationStatus,
        this.image});

  User.fromJson(Map<String?, dynamic> json) {
    if(json['id']!=null)
    id = json['id'].toString();
    if(json['firstname']!=null)
    firstname = json['firstname'];
    if(json['lastname']!=null)
    lastname = json['lastname'];
    if(json['email']!=null)
    email = json['email'];
    if(json['mobile']!=null)
    mobile = json['mobile'];
    if(json['dob']!=null)
    dob = json['dob'];
    if(json['image']!=null)
      image = json['image'];
    if(json['blood_type']!=null)
    bloodType = json['blood_type'];
    if(json['height']!=null)
    height = json['height'];
    if(json['weight']!=null)
    weight = json['weight'];
    if(json['allergies']!=null)
    allergies = json['allergies'];
    if(json['registered']!=null)
    registered = json['registered'];
    if(json['registration_status']!=null)
    registrationStatus = json['registration_status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['firstname'] = this.firstname;
    data['lastname'] = this.lastname;
    data['email'] = this.email;
    data['mobile'] = this.mobile;
    data['dob'] = this.dob;
    data['image'] = this.image;
    data['blood_type'] = this.bloodType;
    data['height'] = this.height;
    data['weight'] = this.weight;
    data['allergies'] = this.allergies;
    data['registered'] = this.registered;
    data['registration_status'] = this.registrationStatus;
    return data;
  }
}