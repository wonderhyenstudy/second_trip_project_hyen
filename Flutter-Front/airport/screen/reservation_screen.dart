import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/airport_constants.dart';
import '../../common/constants/app_colors.dart';
import '../../common/widget/app_base_layout.dart';
import '../../common/widget/common_button.dart';
import '../controller/flight_controller.dart';
import '../controller/reservation_controller.dart';
import '../model/passenger_item.dart';
import '../model/reservation_item.dart';
import '../utils/format_utils.dart';
import '../widget/flight_summary_card.dart';
import '../../services/member_service.dart';
import 'reservation_confirm_screen.dart';

class ReservationScreen extends StatefulWidget {
  const ReservationScreen({super.key});

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {

  // ── 상태 변수 ─────────────────────────────────────────────
  // _isLoading    : 예약 등록 API 호출 중 여부 (버튼 중복 클릭 방지)
  // _bookerName/Email/Phone : MemberService 에서 로드한 예약자 정보
  // _passengers   : 탑승객 목록 (추가/수정/삭제)
  // _adultCount 등: FlightController 에서 가져온 검색 시 선택 인원
  bool _isLoading = false;

  String _bookerName  = '';
  String _bookerEmail = '';
  String _bookerPhone = '';

  final List<PassengerItem> _passengers = [];

  int _adultCount  = 1;
  int _childCount  = 0;
  int _infantCount = 0;
  int get _totalCount => _adultCount + _childCount + _infantCount;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadUserInfo());
  }

  // ── 예약자 정보 자동입력 ──────────────────────────────────
  // MemberService(SecureStorage) 에서 로그인 유저 정보 로드
  // FlightController 에서 검색 시 선택한 인원 정보 로드
  Future<void> _loadUserInfo() async {
    final controller = context.read<FlightController>();
    final userInfo   = await MemberService().getUserInfo();
    debugPrint('[ReservationScreen] 예약자 정보 로드 → ${userInfo['name']}');

    setState(() {
      _bookerName  = userInfo['name']  ?? '';
      _bookerEmail = userInfo['email'] ?? '';
      _bookerPhone = userInfo['phone'] ?? '';
      _adultCount  = controller.adultCount;
      _childCount  = controller.childCount;
      _infantCount = controller.infantCount;
    });
    debugPrint('[ReservationScreen] 인원 → 성인: $_adultCount / 소아: $_childCount / 유아: $_infantCount');
  }

  // ── 탑승객 추가/수정 바텀시트 ────────────────────────────
  // editIndex: null = 추가 / 값 있음 = 수정
  // 이미 추가된 유형 수를 체크해 선택 가능한 유형만 활성화
  // '예약자와 동일' 체크박스: 성인 추가 시에만 표시
  void _showAddPassengerSheet({int? editIndex}) {
    final adultAdded  = _passengers.where((p) => p.passengerType == '성인').length;
    final childAdded  = _passengers.where((p) => p.passengerType == '소아').length;
    final infantAdded = _passengers.where((p) => p.passengerType == '유아').length;

    // 추가 가능한 유형 중 첫 번째를 기본 선택
    String selectedType = editIndex != null
        ? _passengers[editIndex].passengerType
        : (_adultCount > adultAdded ? '성인'
           : _childCount > childAdded ? '소아' : '유아');

    final lastNameCtrl = TextEditingController(
        text: editIndex != null
            ? _passengers[editIndex].passengerName.split(' ').first : '');
    final firstNameCtrl = TextEditingController(
        text: editIndex != null && _passengers[editIndex].passengerName.contains(' ')
            ? _passengers[editIndex].passengerName.split(' ').last : '');
    final birthCtrl = TextEditingController(
        text: editIndex != null ? _passengers[editIndex].passengerBirth : '');
    String selectedGender = editIndex != null
        ? _passengers[editIndex].passengerGender : '남성';

    final formKey    = GlobalKey<FormState>();
    bool sameAsBooker = false;

    debugPrint('[ReservationScreen] 탑승객 ${editIndex != null ? "수정" : "추가"} 시트 열기');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 16, right: 16, top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    // ── 헤더 (추가/수정 타이틀 + 닫기) ────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          editIndex != null ? '탑승객 수정' : '탑승객 추가하기',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // ── 여권 정보 안내 ─────────────────────
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '탑승객 정보는 반드시 여권 정보와 동일해야 해요!',
                        style: TextStyle(fontSize: 12, color: AppColors.primary),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── 예약자와 동일 체크박스 (성인 추가 시만) ──
                    if (selectedType == '성인' && editIndex == null) ...[
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('예약자와 동일',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        value: sameAsBooker,
                        activeColor: AppColors.primary,
                        onChanged: (checked) {
                          setModalState(() {
                            sameAsBooker = checked ?? false;
                            if (sameAsBooker) {
                              lastNameCtrl.text  = _bookerName.isNotEmpty
                                  ? _bookerName.substring(0, 1) : '';
                              firstNameCtrl.text = _bookerName.length > 1
                                  ? _bookerName.substring(1) : '';
                            } else {
                              lastNameCtrl.clear();
                              firstNameCtrl.clear();
                            }
                          });
                          debugPrint('[ReservationScreen] 예약자와 동일: $sameAsBooker');
                        },
                      ),
                      const Divider(),
                    ],

                    const SizedBox(height: 16),

                    // ── 탑승객 유형 선택 ───────────────────
                    // 이미 인원수 만큼 추가된 유형은 비활성화
                    const Text('탑승객 유형', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: ['성인', '소아', '유아'].map((type) {
                        final isAvailable = type == '성인'
                            ? adultAdded < _adultCount
                            : type == '소아'
                            ? childAdded < _childCount
                            : infantAdded < _infantCount;
                        final isSelected = selectedType == type;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: (isAvailable || editIndex != null)
                                ? () {
                                    setModalState(() => selectedType = type);
                                    debugPrint('[ReservationScreen] 탑승객 유형 선택: $type');
                                  }
                                : null,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primary
                                    : (isAvailable || editIndex != null)
                                    ? AppColors.backgroundWhite
                                    : AppColors.backgroundGrey,
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : AppColors.border,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(type,
                                style: TextStyle(
                                  color: isSelected ? Colors.white
                                      : (isAvailable || editIndex != null)
                                      ? AppColors.textPrimary
                                      : AppColors.textSecondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 16),

                    // ── 성 / 이름 입력 ─────────────────────
                    // 한글/영문만 허용, 공백 없이 입력
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('성', style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: lastNameCtrl,
                                decoration: const InputDecoration(
                                  hintText: '홍',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Zㄱ-ㅎ가-힣]')),
                                ],
                                validator: (val) => val == null || val.trim().isEmpty
                                    ? '성을 입력해주세요' : null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('이름', style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: firstNameCtrl,
                                decoration: const InputDecoration(
                                  hintText: '길동',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Zㄱ-ㅎ가-힣]')),
                                ],
                                validator: (val) => val == null || val.trim().isEmpty
                                    ? '이름을 입력해주세요' : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ── 생년월일 입력 (8자리 숫자) ─────────
                    const Text('생년월일', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: birthCtrl,
                      decoration: const InputDecoration(
                        hintText: '예) 19990101',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 8,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return '생년월일을 입력해주세요';
                        if (val.trim().length != 8) return '8자리로 입력해주세요';
                        return null;
                      },
                    ),

                    const SizedBox(height: 8),

                    // ── 성별 선택 ──────────────────────────
                    const Text('성별', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: ['남성', '여성'].map((gender) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Row(
                            children: [
                              Radio<String>(
                                value: gender,
                                groupValue: selectedGender,
                                onChanged: (val) => setModalState(() => selectedGender = val!),
                                activeColor: AppColors.primary,
                              ),
                              Text(gender),
                            ],
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    // ── 취소 / 완료 버튼 ───────────────────
                    // 완료: Form 유효성 검사 → PassengerItem 생성 → 목록에 추가/수정
                    Row(
                      children: [
                        Expanded(
                          child: CommonButton(
                            text: '취소',
                            isOutlined: true,
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: CommonButton(
                            text: '완료',
                            onPressed: () {
                              if (!formKey.currentState!.validate()) return;
                              final name = '${lastNameCtrl.text.trim()} ${firstNameCtrl.text.trim()}';
                              final passenger = PassengerItem(
                                passengerType:   selectedType,
                                passengerName:   name,
                                passengerBirth:  birthCtrl.text.trim(),
                                passengerGender: selectedGender,
                              );
                              setState(() {
                                if (editIndex != null) {
                                  _passengers[editIndex] = passenger;
                                  debugPrint('[ReservationScreen] 탑승객 수정: $name / $selectedType');
                                } else {
                                  _passengers.add(passenger);
                                  debugPrint('[ReservationScreen] 탑승객 추가: $name / $selectedType');
                                }
                              });
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── 예약 등록 ─────────────────────────────────────────────
  // 탑승객 수 체크 → ReservationItem 생성 → addReservation() 호출
  // 성공: ReservationConfirmScreen 이동
  // 실패: 스낵바로 에러 메시지 표시
  Future<void> _onReserve() async {
    debugPrint('[ReservationScreen] 계속 예약 버튼 클릭');
    if (_isLoading) return;

    // 탑승객 수 미충족 시 스낵바 표시
    if (_passengers.length < _totalCount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('탑승객 정보를 모두 입력해주세요. (${_passengers.length}/$_totalCount)')),
      );
      return;
    }

    final flightController = context.read<FlightController>();
    final dep = flightController.selectedDep;
    final ret = flightController.selectedRet;
    if (dep == null) return;

    // SharedPreferences 에서 mid 조회
    final prefs      = await SharedPreferences.getInstance();
    final mid        = prefs.getString('userMid') ?? '';
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final token      = prefs.getString('accessToken') ?? '';
    debugPrint('[ReservationScreen] 로그인: $isLoggedIn / mid: $mid / 토큰: $token');

    // ReservationItem 생성 (가는편 + 오는편 + 탑승객 통합)
    final reservation = ReservationItem(
      mid:             mid,
      airlineNm:       dep.airlineNm,
      flightNo:        dep.flightNo,
      depAirportNm:    dep.depAirportNm,
      arrAirportNm:    dep.arrAirportNm,
      depAirportId:    dep.depAirportId,
      arrAirportId:    dep.arrAirportId,
      depPlandTime:    dep.depPlandTime,
      arrPlandTime:    dep.arrPlandTime,
      depPrice:        dep.price,
      retAirlineNm:    ret?.airlineNm,
      retFlightNo:     ret?.flightNo,
      retDepPlandTime: ret?.depPlandTime,
      retArrPlandTime: ret?.arrPlandTime,
      retPrice:        ret?.price,
      passengers:      _passengers,
      isRoundTrip:     flightController.isRoundTrip,
      reservedAt:      DateTime.now().toString(),
      status:          '예약완료',
    );

    setState(() => _isLoading = true);
    final error = await context.read<ReservationController>().addReservation(reservation);
    setState(() => _isLoading = false);

    if (error != null) {
      // 등록 실패 → 에러 메시지 스낵바
      if (mounted) {
        debugPrint('[ReservationScreen] 예약 등록 실패: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    // 등록 성공 → ReservationConfirmScreen 이동
    if (mounted) {
      debugPrint('[ReservationScreen] 예약 등록 성공 → ReservationConfirmScreen 이동');
      Navigator.push(context,
          MaterialPageRoute(
              builder: (_) => ReservationConfirmScreen(reservation: reservation)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<FlightController>();
    final dep = controller.selectedDep;
    final ret = controller.selectedRet;

    // 선택된 항공편 없으면 에러 화면 (비정상 진입 방지)
    if (dep == null) {
      return const Scaffold(body: Center(child: Text('항공편 정보가 없습니다')));
    }

    // ── 금액 계산 ─────────────────────────────────────────
    // 탑승객 없을 때: 성인 1인 기준 단순 계산
    // 탑승객 있을 때: 유형별 차등 계산 (성인 100% / 소아 75% / 유아 10%)
    final bool hasPassengers  = _passengers.isNotEmpty;
    final passengerTypes      = _passengers.map((p) => p.passengerType).toList();
    final singlePrice         = dep.price + (ret?.price ?? 0) + AirportConstants.issueFee;
    final totalPrice          = hasPassengers
        ? FormatUtils.totalPassengerPrice(
            depPrice:       dep.price,
            retPrice:       ret?.price,
            passengerTypes: passengerTypes,
            issueFee:       AirportConstants.issueFee,
          )
        : singlePrice;

    return AppBaseLayout(
      title: '예약하기',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // ── 출발지 → 도착지 타이틀 ───────────────────
            Text(
              '${controller.depAirportNm} → ${controller.arrAirportNm}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // ── 가는편 요약 카드 ──────────────────────────
            FlightSummaryCard(
              label:      '가는편',
              depTime:    dep.depPlandTime,
              arrTime:    dep.arrPlandTime,
              depAirport: dep.depAirportNm ?? controller.depAirportNm,
              arrAirport: dep.arrAirportNm ?? controller.arrAirportNm,
              airline:    '${dep.airlineNm ?? '-'} ${dep.flightNo ?? '-'}',
              price:      dep.price,
            ),

            // ── 오는편 요약 카드 (왕복일 때만) ───────────
            if (controller.isRoundTrip && ret != null) ...[
              const SizedBox(height: 12),
              FlightSummaryCard(
                label:      '오는편',
                depTime:    ret.depPlandTime,
                arrTime:    ret.arrPlandTime,
                depAirport: ret.depAirportNm ?? controller.arrAirportNm,
                arrAirport: ret.arrAirportNm ?? controller.depAirportNm,
                airline:    '${ret.airlineNm ?? '-'} ${ret.flightNo ?? '-'}',
                price:      ret.price,
              ),
            ],

            const SizedBox(height: 24),

            // ── 예약자 정보 (MemberService 에서 자동 로드) ──
            const Text('예약자 정보',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _infoRow('예약자 이름', _bookerName),
                  const Divider(height: 20),
                  _infoRow('이메일', _bookerEmail),
                  const Divider(height: 20),
                  _infoRow('전화번호', _bookerPhone),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── 탑승객 선택 ───────────────────────────────
            Text('탑승객 선택 (${_passengers.length} / $_totalCount명)',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '예약을 계속 진행하시려면 정확한 승객수 만큼,\n탑승객을 선택/추가해주세요.',
                style: TextStyle(fontSize: 12, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 12),

            // ── 추가된 탑승객 목록 ────────────────────────
            ..._passengers.asMap().entries.map((entry) {
              final index = entry.key;
              final p     = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${p.passengerType} · ${p.passengerName}',
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text('${p.passengerBirth} · ${p.passengerGender}',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => _showAddPassengerSheet(editIndex: index),
                      child: const Text('수정', style: TextStyle(color: AppColors.primary)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 16, color: AppColors.textSecondary),
                      onPressed: () {
                        setState(() => _passengers.removeAt(index));
                        debugPrint('[ReservationScreen] 탑승객 삭제: ${p.passengerName}');
                      },
                    ),
                  ],
                ),
              );
            }),

            // ── 탑승객 추가하기 버튼 ──────────────────────
            if (_passengers.length < _totalCount) ...[
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _showAddPassengerSheet,
                icon: const Icon(Icons.add, color: AppColors.primary),
                label: const Text('탑승객 추가하기',
                    style: TextStyle(color: AppColors.primary)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // ── 금액 요약 ─────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.backgroundGrey,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [

                  // 탑승객 미입력: 성인 1인 기준
                  if (!hasPassengers) ...[
                    _priceRow('가는편 (성인 1인 기준)', dep.price),
                    if (controller.isRoundTrip && ret != null) ...[
                      const SizedBox(height: 8),
                      _priceRow('오는편 (성인 1인 기준)', ret.price),
                    ],
                  ],

                  // 탑승객 입력 후: 유형별 차등 가격 표시
                  if (hasPassengers) ...[
                    ..._passengers.map((p) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _priceRow(
                        '가는편 ${p.passengerType} (${p.passengerName})',
                        FormatUtils.passengerPrice(dep.price, p.passengerType),
                      ),
                    )),
                    if (controller.isRoundTrip && ret != null)
                      ..._passengers.map((p) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _priceRow(
                          '오는편 ${p.passengerType} (${p.passengerName})',
                          FormatUtils.passengerPrice(ret.price, p.passengerType),
                        ),
                      )),
                  ],

                  const SizedBox(height: 8),
                  _priceRow('발급 수수료', AirportConstants.issueFee, isGrey: true),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        hasPassengers ? '총 결제금액' : '결제 예상금액 (1인 기준)',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        FormatUtils.price(totalPrice),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── 유의사항 안내 ─────────────────────────────
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFDE7),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFFF176)),
              ),
              child: const Text(
                '· 발권 후 취소/변경 시 취소 수수료가 발생할 수 있습니다.\n'
                '· 유류할증료는 항공사 정책에 따라 변경될 수 있습니다.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ),

            const SizedBox(height: 32),

            // ── 계속 예약 버튼 ────────────────────────────
            // 탑승객 수 미충족 or 로딩 중이면 비활성화
            CommonButton(
              text: '계속 예약',
              onPressed: _onReserve,
              isEnabled: !_isLoading && _passengers.length == _totalCount,
            ),
          ],
        ),
      ),
    );
  }

  // ── 정보 행 위젯 ──────────────────────────────────────────
  // 예약자 정보 섹션에서 label / value 한 행 표시
  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary)),
        Text(value.isEmpty ? '-' : value,
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  // ── 금액 행 위젯 ──────────────────────────────────────────
  // 금액 요약 섹션에서 label / price 한 행 표시
  // isGrey: true 이면 발급 수수료처럼 회색으로 표시
  Widget _priceRow(String label, int price, {bool isGrey = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(color: isGrey ? AppColors.textSecondary : AppColors.textPrimary)),
        Text(FormatUtils.price(price),
            style: TextStyle(color: isGrey ? AppColors.textSecondary : AppColors.textPrimary)),
      ],
    );
  }
}

// =============================================================================
// [파일 정보]
// 위치  : lib/airport/screen/reservation_screen.dart
// 역할  : 항공권 예약 진행 화면 (예약자 정보 / 탑승객 입력 / 금액 확인)
// 사용처 : FlightDetailScreen 에서 '항공권 예약' 버튼 클릭 시 이동
// -----------------------------------------------------------------------------
// [연관 파일]
// - flight_controller.dart        : selectedDep, selectedRet, adultCount 등
// - reservation_controller.dart   : addReservation() 호출
// - reservation_item.dart         : 예약 데이터 모델
// - passenger_item.dart           : 탑승객 데이터 모델
// - member_service.dart           : 예약자 정보 로드 (getUserInfo)
// - airport_constants.dart        : issueFee (발급 수수료)
// - format_utils.dart             : price(), passengerPrice(), totalPassengerPrice()
// - flight_summary_card.dart      : 가는편/오는편 요약 카드 위젯
// - reservation_confirm_screen.dart : 예약 성공 시 이동
// -----------------------------------------------------------------------------
// [변경 이력]
// - 최초 작성 : 단일 탑승객 입력 구조
// - 변경       : 탑승객 다중 입력 구조로 확장 (List<PassengerItem>)
//               소아/유아 가격 차등 계산 추가 (FormatUtils.passengerPrice)
//               MemberService 로 예약자 정보 자동입력
//               '예약자와 동일' 체크박스 추가
// -----------------------------------------------------------------------------
// [메서드 목록]
// - _loadUserInfo()              : 예약자 정보 + 인원 정보 로드
// - _showAddPassengerSheet(...)  : 탑승객 추가/수정 바텀시트
// - _onReserve()                 : 탑승객 수 체크 → 예약 등록 → 결과 처리
// - build()                      : 화면 구성 (항공편 요약 / 예약자 / 탑승객 / 금액)
// - _infoRow(...)                : 정보 행 위젯
// - _priceRow(...)               : 금액 행 위젯
// -----------------------------------------------------------------------------
// [파일 흐름과 순서]
// 1. FlightDetailScreen → '항공권 예약' 버튼 → ReservationScreen 진입
// 2. initState() → _loadUserInfo() → 예약자 정보 + 인원 자동 로드
// 3. '탑승객 추가하기' 버튼 → _showAddPassengerSheet() → 탑승객 입력
// 4. 탑승객 수 = 선택 인원 수 → '계속 예약' 버튼 활성화
// 5. '계속 예약' 클릭 → _onReserve() → addReservation() 호출
//    → 성공: ReservationConfirmScreen 이동
//    → 실패: 스낵바 에러 메시지
// -----------------------------------------------------------------------------
// [주의사항 / 참고]
// - mid 는 SharedPreferences 에서 조회 (MemberService 통해 이미 저장된 값)
// - 탑승객 수가 선택 인원과 정확히 일치해야 '계속 예약' 버튼 활성화
// - 소아/유아 가격 차등: FormatUtils.passengerPrice() 참고
// - '예약자와 동일' 체크박스는 이름만 자동입력 (생년월일/성별은 직접 입력)
// =============================================================================