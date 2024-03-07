// Model to hold the student data

class StudentProfile {
  final String name;
  final String admissionNo;
  final String rollNo;
  final String? behaviourScore;
  final String classInfo;
  final String imgUrl;
  final String barcodeUrl;
  final String? pickupPointName;
  final String? routePickupPointId;
  final String? transportFees;
  final String? parentAppKey;
  final String? vehrouteId;
  final String? routeId;
  final String? vehicleId;
  final String? routeTitle;
  final String? vehicleNo;
  final String? roomNo;
  final String? driverName;
  final String? driverContact;
  final String? vehicleModel;
  final String? manufactureYear;
  final String? driverLicence;
  final String? vehiclePhoto;
  final String? hostelId;
  final String? hostelName;
  final String? roomTypeId;
  final String? roomType;
  final String? hostelRoomId;
  final String? studentSessionId;
  final String? feesDiscount;
  final String? classId;
  final String? sectionId;
  final String? admissionDate;
  final String? firstName;
  final String? middleName;
  final String? lastName;
  final String? mobileNo;
  final String? email;
  final String? state;
  final String? city;
  final String? pincode;
  final String? note;
  final String? religion;
  final String? cast;
  final String? houseName;
  final String? dob;
  final String? currentAddress;
  final String? previousSchool;
  final String? guardianIs;
  final String? parentId;
  final String? permanentAddress;
  final String? categoryId;
  final String? category;
  final String? adharNo;
  final String? samagraId;
  final String? bankAccountNo;
  final String? bankName;
  final String? ifscCode;
  final String? guardianName;
  final String? fatherPic;
  final String? height;
  final String? weight;
  final String? measurementDate;
  final String? motherPic;
  final String? guardianPic;
  final String? guardianRelation;
  final String? guardianPhone;
  final String? guardianAddress;
  final String? isActive;
  final String? createdAt;
  final String? updatedAt;
  final String? fatherName;
  final String? fatherPhone;
  final String? bloodGroup;
  final String? schoolHouseId;
  final String? fatherOccupation;
  final String? motherName;
  final String? motherPhone;
  final String? motherOccupation;
  final String? guardianOccupation;
  final String? gender;
  final String? rte;
  final String? guardianEmail;
  final String? username;
  final String? password;
  final String? disReason;
  final String? disNote;
  final String? disableAt;
  final String? currencyName;
  final String? symbol;
  final String? basePrice;
  final String? currencyId;
  final String? sessionId;
  final String? session;

  // Constructor with all fields
  StudentProfile({
    required this.name,
    required this.admissionNo,
    required this.rollNo,
    this.behaviourScore,
    required this.classInfo,
    required this.imgUrl,
    required this.barcodeUrl,
    this.pickupPointName,
    this.routePickupPointId,
    this.transportFees,
    this.parentAppKey,
    this.vehrouteId,
    this.routeId,
    this.vehicleId,
    this.routeTitle,
    this.vehicleNo,
    this.roomNo,
    this.driverName,
    this.driverContact,
    this.vehicleModel,
    this.manufactureYear,
    this.driverLicence,
    this.vehiclePhoto,
    this.hostelId,
    this.hostelName,
    this.roomTypeId,
    this.roomType,
    this.hostelRoomId,
    this.studentSessionId,
    this.feesDiscount,
    this.classId,
    this.sectionId,
    this.admissionDate,
    this.firstName,
    this.middleName,
    this.lastName,
    this.mobileNo,
    this.email,
    this.state,
    this.city,
    this.pincode,
    this.note,
    this.religion,
    this.cast,
    this.houseName,
    this.dob,
    this.currentAddress,
    this.previousSchool,
    this.guardianIs,
    this.parentId,
    this.permanentAddress,
    this.categoryId,
    this.category,
    this.adharNo,
    this.samagraId,
    this.bankAccountNo,
    this.bankName,
    this.ifscCode,
    this.guardianName,
    this.fatherPic,
    this.height,
    this.weight,
    this.measurementDate,
    this.motherPic,
    this.guardianPic,
    this.guardianRelation,
    this.guardianPhone,
    this.guardianAddress,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.fatherName,
    this.fatherPhone,
    this.bloodGroup,
    this.schoolHouseId,
    this.fatherOccupation,
    this.motherName,
    this.motherPhone,
    this.motherOccupation,
    this.guardianOccupation,
    this.gender,
    this.rte,
    this.guardianEmail,
    this.username,
    this.password,
    this.disReason,
    this.disNote,
    this.disableAt,
    this.currencyName,
    this.symbol,
    this.basePrice,
    this.currencyId,
    this.sessionId,
    this.session,
  });

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    var studentResult = json['student_result'];
    return StudentProfile(
      name: '${studentResult['firstname']} ${studentResult['lastname']}',
      admissionNo: studentResult['admission_no'] ?? "",
      rollNo: studentResult['roll_no'] ?? "",
      behaviourScore: studentResult['behaviou_score']?.toString(),
      classInfo:
          '${studentResult['class']} - ${studentResult['section']} (${studentResult['session']})',
      imgUrl: studentResult['image'] ?? "",
      barcodeUrl: studentResult['barcode'] ?? "",
      pickupPointName: studentResult['pickup_point_name'],
      routePickupPointId: studentResult['route_pickup_point_id'],
      transportFees: studentResult['transport_fees'],
      parentAppKey: studentResult['parent_app_key'],
      vehrouteId: studentResult['vehroute_id'],
      routeId: studentResult['route_id'],
      vehicleId: studentResult['vehicle_id'],
      routeTitle: studentResult['route_title'],
      vehicleNo: studentResult['vehicle_no'],
      roomNo: studentResult['room_no'],
      driverName: studentResult['driver_name'],
      driverContact: studentResult['driver_contact'],
      vehicleModel: studentResult['vehicle_model'],
      manufactureYear: studentResult['manufacture_year'],
      driverLicence: studentResult['driver_licence'],
      vehiclePhoto: studentResult['vehicle_photo'],
      hostelId: studentResult['hostel_id'],
      hostelName: studentResult['hostel_name'],
      roomTypeId: studentResult['room_type_id'],
      roomType: studentResult['room_type'],
      hostelRoomId: studentResult['hostel_room_id'],
      studentSessionId: studentResult['student_session_id'],
      feesDiscount: studentResult['fees_discount'],
      classId: studentResult['class_id'],
      sectionId: studentResult['section_id'],
      admissionDate: studentResult['admission_date'],
      firstName: studentResult['firstname'],
      middleName: studentResult['middlename'],
      lastName: studentResult['lastname'],
      mobileNo: studentResult['mobileno'],
      email: studentResult['email'],
      state: studentResult['state'],
      city: studentResult['city'],
      pincode: studentResult['pincode'],
      note: studentResult['note'],
      religion: studentResult['religion'],
      cast: studentResult['cast'],
      houseName: studentResult['house_name'],
      dob: studentResult['dob'],
      currentAddress: studentResult['current_address'],
      previousSchool: studentResult['previous_school'],
      guardianIs: studentResult['guardian_is'],
      parentId: studentResult['parent_id'],
      permanentAddress: studentResult['permanent_address'],
      categoryId: studentResult['category_id'],
      category: studentResult['category'],
      adharNo: studentResult['adhar_no'],
      samagraId: studentResult['samagra_id'],
      bankAccountNo: studentResult['bank_account_no'],
      bankName: studentResult['bank_name'],
      ifscCode: studentResult['ifsc_code'],
      guardianName: studentResult['guardian_name'],
      fatherPic: studentResult['father_pic'],
      height: studentResult['height'],
      weight: studentResult['weight'],
      measurementDate: studentResult['measurement_date'],
      motherPic: studentResult['mother_pic'],
      guardianPic: studentResult['guardian_pic'],
      guardianRelation: studentResult['guardian_relation'],
      guardianPhone: studentResult['guardian_phone'],
      guardianAddress: studentResult['guardian_address'],
      isActive: studentResult['is_active'],
      createdAt: studentResult['created_at'],
      updatedAt: studentResult['updated_at'],
      fatherName: studentResult['father_name'],
      fatherPhone: studentResult['father_phone'],
      bloodGroup: studentResult['blood_group'],
      schoolHouseId: studentResult['school_house_id'],
      fatherOccupation: studentResult['father_occupation'],
      motherName: studentResult['mother_name'],
      motherPhone: studentResult['mother_phone'],
      motherOccupation: studentResult['mother_occupation'],
      guardianOccupation: studentResult['guardian_occupation'],
      gender: studentResult['gender'],
      rte: studentResult['rte'],
      guardianEmail: studentResult['guardian_email'],
      username: studentResult['username'],
      password: studentResult['password'],
      disReason: studentResult['dis_reason'],
      disNote: studentResult['dis_note'],
      disableAt: studentResult['disable_at'],
      currencyName: studentResult['currency_name'],
      symbol: studentResult['symbol'],
      basePrice: studentResult['base_price'],
      currencyId: studentResult['currency_id'],
      sessionId: studentResult['session_id'],
      session: studentResult['session'],
    );
  }
}
