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
  final _descriptionController = TextEditingController();

  bool _allDay = false;
  late DateTime _startDate;
  late DateTime _endDate;
  ScheduleType _type = ScheduleType.etc;

  String _repeatType = 'NONE';
  int? _alarmOffsetMinutes;
  bool _isAnniversary = false;
  bool _isImportant = false;

  @override
  void initState() {
    super.initState();
    if (widget.schedule != null) {
      _titleController.text = widget.schedule!.title;
      _descriptionController.text = widget.schedule!.description ?? '';
      _allDay = widget.schedule!.allDay;
      _startDate = widget.schedule!.startDateTime;
      _endDate = widget.schedule!.endDateTime;
      _type = widget.schedule!.type;
      _repeatType = widget.schedule!.repeatType;
      _alarmOffsetMinutes = widget.schedule!.alarmOffsetMinutes;
      _isAnniversary = widget.schedule!.isAnniversary;
      _isImportant = widget.schedule!.isImportant;
    } else {
      final now = widget.initialDate ?? DateTime.now();
      // Default to next hour or current if all day
      _startDate = now;
      _endDate = now.add(const Duration(hours: 1));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
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
                              if (_allDay) {
                                // Set to start of day and end of day
                                _startDate = DateTime(
                                  _startDate.year,
                                  _startDate.month,
                                  _startDate.day,
                                  0,
                                  0,
                                );
                                _endDate = DateTime(
                                  _endDate.year,
                                  _endDate.month,
                                  _endDate.day,
                                  23,
                                  59,
                                );
                              }
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
                      // Start Date
                      Expanded(
                        child: _buildDateTimePicker(
                          date: _startDate,
                          onDateChanged: (newDate) {
                            setState(() {
                              _startDate = newDate;
                              if (_startDate.isAfter(_endDate)) {
                                _endDate = _startDate.add(
                                  const Duration(hours: 1),
                                );
                              }
                            });
                          },
                        ),
                      ),
                      // Arrow
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Icon(
                          Icons.arrow_forward,
                          size: 16,
                          color: Color(0xFFDEDEDE),
                        ),
                      ),
                      // End Date
                      Expanded(
                        child: _buildDateTimePicker(
                          date: _endDate,
                          onDateChanged: (newDate) {
                            setState(() {
                              _endDate = newDate;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: Color(0xFFDEDEDE)),

                  // Repeat
                  _buildOptionRow(
                    icon: Icons.repeat,
                    label: '반복',
                    value: _getRepeatLabel(_repeatType),
                    onTap: _showRepeatPicker,
                  ),
                  const Divider(height: 1, color: Color(0xFFDEDEDE)),

                  // Alarm
                  _buildOptionRow(
                    icon: Icons.notifications_none,
                    label: '알림',
                    value: _getAlarmLabel(_alarmOffsetMinutes),
                    onTap: _showAlarmPicker,
                  ),
                  const Divider(height: 1, color: Color(0xFFDEDEDE)),

                  // Description
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.description_outlined,
                          size: 20,
                          color: Color(0xFF6A6A6A),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          '설명',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6A6A6A),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _descriptionController,
                            maxLines: null,
                            decoration: const InputDecoration.collapsed(
                              hintText: '설명 추가',
                              hintStyle: TextStyle(
                                fontSize: 13,
                                color: Color(0xFFB0B0B0),
                              ),
                            ),
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6A6A6A),
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFDEDEDE)),

                  // Anniversary Toggle
                  _buildSwitchRow(
                    icon: Icons.cake_outlined,
                    label: '기념일',
                    value: _isAnniversary,
                    onChanged: (val) {
                      setState(() {
                        _isAnniversary = val;
                        // If anniversary, maybe default repeat to yearly?
                        // For now keeping logic simple as requested.
                      });
                    },
                  ),
                  const Divider(height: 1, color: Color(0xFFDEDEDE)),

                  // Important Toggle
                  _buildSwitchRow(
                    icon: Icons.favorite_border,
                    label: '챙기기',
                    value: _isImportant,
                    onChanged: (val) {
                      setState(() {
                        _isImportant = val;
                      });
                    },
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
              onTap: _saveSchedule,
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

  Widget _buildDateTimePicker({
    required DateTime date,
    required Function(DateTime) onDateChanged,
  }) {
    return GestureDetector(
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (pickedDate != null) {
          DateTime result;
          if (_allDay) {
            result = DateTime(
              pickedDate.year,
              pickedDate.month,
              pickedDate.day,
              date.hour,
              date.minute,
            );
            if (date.hour == 23 && date.minute == 59) {
              // keep it end of day if it was end of day
              result = DateTime(
                pickedDate.year,
                pickedDate.month,
                pickedDate.day,
                23,
                59,
              );
            } else if (date.hour == 0 && date.minute == 0) {
              result = DateTime(
                pickedDate.year,
                pickedDate.month,
                pickedDate.day,
                0,
                0,
              );
            }
          } else {
            final time = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.fromDateTime(date),
            );
            if (time != null) {
              result = DateTime(
                pickedDate.year,
                pickedDate.month,
                pickedDate.day,
                time.hour,
                time.minute,
              );
            } else {
              return; // Cancelled time picker
            }
          }
          onDateChanged(result);
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('yy.MM.dd.(E)', 'ko_KR').format(date),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w300,
              color: Color(0xFF424242),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _allDay && (date.hour == 0 && date.minute == 0)
                ? '오전 00:00'
                : _allDay && (date.hour == 23 && date.minute == 59)
                ? '오후 11:59'
                : DateFormat('a hh:mm', 'ko_KR').format(date),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: _allDay
                  ? Colors.transparent
                  : const Color(
                      0xFF424242,
                    ), // Hide time text visually but keep space?
              // Actually user request says "Hide time selection UI"
              // But here I am just hiding the text or making it transparent as per original implementation hint.
            ),
          ),
          if (_allDay)
            // Show alternative text or nothing?
            // Request says: "Time selection UI is hidden or disabled".
            // Since we are reusing the widget, let's just show date.
            const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _buildOptionRow({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.translucent,
      child: Padding(
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
            Text(
              value,
              style: const TextStyle(fontSize: 13, color: Color(0xFF6A6A6A)),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Color(0xFFDEDEDE)),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchRow({
    required IconData icon,
    required String label,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFF6A6A6A)),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(fontSize: 13, color: Color(0xFF6A6A6A)),
              ),
            ],
          ),
          SizedBox(
            height: 20,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.black,
              activeTrackColor: const Color(0xFFE1E1E1),
              inactiveThumbColor: const Color(0xFFFFFFFF),
              inactiveTrackColor: const Color(0xFFE1E1E1),
            ),
          ),
        ],
      ),
    );
  }

  void _showRepeatPicker() {
    // Simple sheet or dialog
    Get.bottomSheet(
      Container(
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['NONE', 'DAILY', 'WEEKLY', 'MONTHLY', 'YEARLY']
              .map(
                (type) => ListTile(
                  title: Text(_getRepeatLabel(type)),
                  onTap: () {
                    setState(() => _repeatType = type);
                    Get.back();
                  },
                  trailing: _repeatType == type
                      ? const Icon(Icons.check, color: Colors.blue)
                      : null,
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  String _getRepeatLabel(String type) {
    switch (type) {
      case 'NONE':
        return '없음';
      case 'DAILY':
        return '매일';
      case 'WEEKLY':
        return '매주';
      case 'MONTHLY':
        return '매월';
      case 'YEARLY':
        return '매년';
      default:
        return '없음';
    }
  }

  void _showAlarmPicker() {
    Get.bottomSheet(
      Container(
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _alarmOption(null, '없음'),
            _alarmOption(10, '10분 전'),
            _alarmOption(60, '1시간 전'),
            _alarmOption(1440, '1일 전'),
          ],
        ),
      ),
    );
  }

  Widget _alarmOption(int? minutes, String label) {
    return ListTile(
      title: Text(label),
      onTap: () {
        setState(() => _alarmOffsetMinutes = minutes);
        Get.back();
      },
      trailing: _alarmOffsetMinutes == minutes
          ? const Icon(Icons.check, color: Colors.blue)
          : null,
    );
  }

  String _getAlarmLabel(int? minutes) {
    if (minutes == null) return '없음';
    if (minutes == 10) return '10분 전';
    if (minutes == 60) return '1시간 전';
    if (minutes == 1440) return '1일 전';
    return '$minutes분 전';
  }

  void _saveSchedule() {
    if (_titleController.text.trim().isEmpty) {
      Get.snackbar('오류', '일정 제목을 입력해주세요', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final newSchedule = Schedule(
      id: widget.schedule?.id ?? const Uuid().v4(),
      title: _titleController.text,
      startDateTime: _startDate,
      endDateTime: _endDate,
      allDay: _allDay,
      type: _type, // Keep existing type logc or default
      personIds:
          widget.schedule?.personIds ??
          (widget.personId != null ? [widget.personId!] : []),
      isPlanned: widget.isPlanned,
      repeatType: _repeatType,
      alarmOffsetMinutes: _alarmOffsetMinutes,
      description: _descriptionController.text,
      isAnniversary: _isAnniversary,
      isImportant: _isImportant,
    );

    Get.back(result: newSchedule);
  }
}
