class ProfileModel {
  final String employeeNo;
  final String joinedDate;
  final String country;
  final String position;
  final String surname;
  final String otherName;
  final String birthday;
  final String passportNo;
  final String email;
  final String gender;
  final String mobileNumber;
  final String whatsAppNumber;

  const ProfileModel({
    required this.employeeNo,
    required this.joinedDate,
    required this.country,
    required this.position,
    required this.surname,
    required this.otherName,
    required this.birthday,
    required this.passportNo,
    required this.email,
    required this.gender,
    required this.mobileNumber,
    required this.whatsAppNumber,
  });

  // Hardcoded dummy data — replace with API response later
  static const dummy = ProfileModel(
    employeeNo: 'SDI546382',
    joinedDate: '23 Sep 2020',
    country: 'Sri Lanka',
    position: 'Employee',
    surname: 'Dulaj',
    otherName: 'Kosala',
    birthday: '12 Apr 1994',
    passportNo: '2342934298394299',
    email: 'dulaj@gmail.com',
    gender: 'Male',
    mobileNumber: '+94 11 234 5678',
    whatsAppNumber: '+94 11 234 5678',
  );
}
