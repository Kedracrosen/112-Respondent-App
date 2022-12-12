

class a {
  String? address;
  String? lattitude;
  String? name;
  String? type;
  String? channelId;
  String? longitude;

  a(
      {this.address,
        this.lattitude,
        this.name,
        this.type,
        this.channelId,
        this.longitude});

  a.fromJson(Map<String, dynamic> json) {
    address = json['a']['address'];
    lattitude = json['a']['lattitude'];
    name = json['a']['name'];
    type = json['a']['type'];
    channelId = json['a']['channel_id'];
    longitude = json['a']['longitude'];
  }

  Map<String?, dynamic> toJson() {
    final Map<String?, dynamic> data = new Map<String?, dynamic>();
    data['address'] = this.address;
    data['lattitude'] = this.lattitude;
    data['name'] = this.name;
    data['type'] = this.type;
    data['channel_id'] = this.channelId;
    data['longitude'] = this.longitude;
    return data;
  }
}

class ActionButtons {
  String? id;
  String? text;
  String? icon;

  ActionButtons({this.id, this.text, this.icon});

  ActionButtons.fromJson(Map<String?, dynamic> json) {
    id = json['id'];
    text = json['text'];
    icon = json['icon'];
  }

  Map<String?, dynamic> toJson() {
    final Map<String?, dynamic> data = new Map<String?, dynamic>();
    data['id'] = this.id;
    data['text'] = this.text;
    data['icon'] = this.icon;
    return data;
  }
}
