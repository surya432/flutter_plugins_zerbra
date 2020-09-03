class DevicesListBT {
  String name;
  String mac;

  DevicesListBT({this.name, this.mac});

  DevicesListBT.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    mac = json['mac'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['mac'] = this.mac;
    return data;
  }
}
