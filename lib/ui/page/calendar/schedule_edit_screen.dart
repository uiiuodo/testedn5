import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../../data/model/schedule.dart';

class ScheduleEditScreen extends StatefulWidget {
  final Schedule? schedule;
  final DateTime? initialDate;
  final bool isPlanned;
  final String? personId; // To link schedule to a person

  const ScheduleEditScreen({
    super.key,
    this.schedule,
    this.initialDate,
    this.isPlanned = false,
    this.personId,
  });

  @override
  State<ScheduleEditScreen> createState() => _ScheduleEditScreenState();
}

class _ScheduleEditScreenState extends State<ScheduleEditScreen> {
  final _titleController = TextEditingController();
  bool _allDay = false;
  late DateTime _startDate;
  late DateTime _endDate;
  ScheduleType _type = ScheduleType.etc;

  @override
  void initState() {
    super.initState();
    if (widget.schedule != null) {
      _titleController.text = widget.schedule!.title;
      _allDay = widget.schedule!.allDay;
      _startDate = widget.schedule!.startDateTime;
      _endDate = widget.schedule!.endDateTime;
      _type = widget.schedule!.type;
    } else {
      final now = widget.initialDate ?? DateTime.now();
      _startDate = now;
      _endDate = now.add(const Duration(hours: 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height:
          MediaQuery.of(context).size.height *
          0.85, // Occupy significant height
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Get.back(),
                  child: const Icon(Icons.close, size: 24, color: Colors.black),
                ),
                const SizedBox(width: 16),
                const Text(
                  '일정',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2A2A2A),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFDEDEDE)),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // Title Input
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      hintText: '일정을 입력하세요',
                      hintStyle: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w300,
                        color: Color(0xFF939393),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(height: 1, color: Color(0xFFDEDEDE)),

                  // All Day Toggle
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 20,
                              color: Color(0xFF6A6A6A),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              '종일',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6A6A6A),
                              ),
                            ),
                          ],
                        ),
                        Switch(
                          value: _allDay,
                          onChanged: (val) {
                            setState(() {
                              _allDay = val;
                            });
                          },
                          activeColor: Colors.black,
                          activeTrackColor: const Color(0xFFE1E1E1),
                          inactiveThumbColor: const Color(0xFFFFFFFF),
                          inactiveTrackColor: const Color(0xFFE1E1E1),
                        ),
                      ],
                    ),
                  ),

                  // Date & Time Selection
                  Row(
                    children: [
                      // Start Date/Time
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _startDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (date != null) {
                              if (_allDay) {
                                setState(() {
                                  _startDate = date;
                                  if (_startDate.isAfter(_endDate)) {
                                    _endDate = _startDate;
                                  }
                                });
                              } else {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.fromDateTime(
                                    _startDate,
                                  ),
                                );
                                if (time != null) {
                                  setState(() {
                                    _startDate = DateTime(
                                      date.year,
                                      date.month,
                                      date.day,
                                      time.hour,
                                      time.minute,
                                    );
                                    if (_startDate.isAfter(_endDate)) {
                                      _endDate = _startDate.add(
                                        const Duration(hours: 1),
                                      );
                                    }
                                  });
                                }
                              }
                            }
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat(
                                  'yy.MM.dd.(E)',
                                  'ko_KR',
                                ).format(_startDate),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w300,
                                  color: Color(0xFF424242),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _allDay
                                    ? '오전 00:00' // Placeholder for All Day
                                    : DateFormat(
                                        'a hh:mm',
                                        'ko_KR',
                                      ).format(_startDate),
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  color: _allDay
                                      ? Colors.transparent
                                      : const Color(0xFF424242),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Arrow Icon
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Icon(
                          Icons.arrow_forward,
                          size: 16,
                          color: Color(0xFFDEDEDE),
                        ),
                      ),
                      // End Date/Time
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _endDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (date != null) {
                              if (_allDay) {
                                setState(() {
                                  _endDate = date;
                                });
                              } else {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.fromDateTime(_endDate),
                                );
                                if (time != null) {
                                  setState(() {
                                    _endDate = DateTime(
                                      date.year,
                                      date.month,
                                      date.day,
                                      time.hour,
                                      time.minute,
                                    );
                                  });
                                }
                              }
                            }
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat(
                                  'yy.MM.dd.(E)',
                                  'ko_KR',
                                ).format(_endDate),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w300,
                                  color: Color(0xFF424242),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _allDay
                                    ? '오후 11:59' // Placeholder for All Day
                                    : DateFormat(
                                        'a hh:mm',
                                        'ko_KR',
                                      ).format(_endDate),
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  color: _allDay
                                      ? Colors.transparent
                                      : const Color(0xFF424242),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: Color(0xFFDEDEDE)),

                  // Extra Options (Repeat, Notification, Description, Anniversary, Care)
                  _buildOptionRow(icon: Icons.repeat, label: '반복', value: '없음'),
                  const Divider(height: 1, color: Color(0xFFDEDEDE)),
                  _buildOptionRow(
                    icon: Icons.notifications_none,
                    label: '알림',
                    value: '없음',
                  ),
                  const Divider(height: 1, color: Color(0xFFDEDEDE)),
                  _buildOptionRow(
                    icon: Icons.description_outlined,
                    label: '설명',
                    value: '',
                    isDescription: true,
                  ),
                  const Divider(height: 1, color: Color(0xFFDEDEDE)),
                  _buildOptionRow(
                    icon: Icons.cake_outlined,
                    label: '기념일',
                    isToggle: true,
                  ),
                  const Divider(height: 1, color: Color(0xFFDEDEDE)),
                  _buildOptionRow(
                    icon: Icons.favorite_border,
                    label: '챙기기',
                    isToggle: true,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // Bottom Button
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: GestureDetector(
              onTap: () {
                if (_titleController.text.isEmpty) {
                  Get.snackbar('오류', '제목을 입력해주세요');
                  return;
                }

                final newSchedule = Schedule(
                  id: widget.schedule?.id ?? const Uuid().v4(),
                  title: _titleController.text,
                  startDateTime: _startDate,
                  endDateTime: _endDate,
                  allDay: _allDay,
                  type: _type,
                  personIds:
                      widget.schedule?.personIds ??
                      (widget.personId != null ? [widget.personId!] : []),
                  isPlanned: widget.isPlanned,
                );

                Get.back(result: newSchedule);
              },
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF414141),
                  borderRadius: BorderRadius.circular(28),
                ),
                alignment: Alignment.center,
                child: Text(
                  widget.schedule != null ? '수정하기' : '추가하기',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionRow({
    required IconData icon,
    required String label,
    String? value,
    bool isToggle = false,
    bool isDescription = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF6A6A6A)),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF6A6A6A)),
          ),
          const Spacer(),
          if (isToggle)
            // TODO: Implement toggle logic
            SizedBox(
              height: 20,
              child: Switch(
                value: false, // Dummy value
                onChanged: (val) {},
                activeColor: Colors.black,
              ),
            )
          else if (isDescription)
            // TODO: Implement description input
            const Icon(Icons.chevron_right, color: Color(0xFFDEDEDE))
          else
            Row(
              children: [
                if (value != null)
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6A6A6A),
                    ),
                  ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: Color(0xFFDEDEDE)),
              ],
            ),
        ],
      ),
    );
  }
}
