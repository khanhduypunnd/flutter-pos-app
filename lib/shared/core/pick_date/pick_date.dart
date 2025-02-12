import 'package:flutter/material.dart';

import '../theme/colors.dart';

class TimeSelection extends StatefulWidget {
  final Function(DateTime?, DateTime?) onDateSelected;
  const TimeSelection({super.key, required this.onDateSelected});

  @override
  State<TimeSelection> createState() => _TimeSelectionContainerState();
}

class _TimeSelectionContainerState extends State<TimeSelection> {
  String selectedDate = 'Hôm nay';
  DateTime? startDate;
  DateTime? endDate;


  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      child: Container(
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        width: 200,
        child: DropdownButton<String>(
          value: selectedDate,
          elevation: 16,
          style: const TextStyle(color: Colors.deepPurple),
          underline: Container(
            height: 0,
          ),
          onChanged: (String? newValue) {
            setState(() {
              selectedDate = newValue!;
            });
            _handleDateSelection(newValue!);
          },
          items: <String>['Hôm nay', 'Hôm qua', '7 ngày trước', '30 ngày trước', 'Tháng này', 'Tháng trước', 'Tùy chỉnh']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: TextStyle(color: AppColors.subtitleColor, fontSize: 15),),
            );
          }).toList(),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(10),
          itemHeight: 48,
          isExpanded: true,
        ),
      ),
    );
  }

  void _handleDateSelection(String value) {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);

    switch (value) {
      case 'Hôm nay':
        startDate = today;
        endDate = today;
        break;
      case 'Hôm qua':
        startDate = today.subtract(Duration(days: 1));
        endDate = today.subtract(Duration(days: 1));
        break;
      case '7 ngày trước':
        startDate = today.subtract(Duration(days: 7));
        endDate = today.subtract(Duration(days: 1));
        break;
      case 'Tháng này':
        startDate = DateTime(today.year, today.month, 1);
        endDate = DateTime(today.year, today.month + 1, 0);
        break;
      case 'Tháng trước':
        startDate = DateTime(today.year, today.month - 1, 1);
        endDate = DateTime(today.year, today.month, 0);
        break;
      case '30 ngày trước':
        startDate = today.subtract(Duration(days: 30));
        endDate = today.subtract(Duration(days: 1));
        break;
      case 'Tùy chỉnh':
        _showCustomDatePicker(context);
        return;
    }

    setState(() {
      selectedDate = value;
    });

    widget.onDateSelected(startDate, endDate);
  }


  Future<void> _showCustomDatePicker(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        DateTime? tempStartDate;
        DateTime? tempEndDate;

        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Chọn khoảng thời gian', style: TextStyle(color: AppColors.titleColor),),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Chọn ngày bắt đầu', style: TextStyle(color: AppColors.titleColor)),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    tempStartDate = await _selectDate(context);
                    if (tempStartDate != null) {
                      setState(() {
                        tempStartDate = tempStartDate;
                      });
                    }
                  },
                ),
              ),
              ListTile(
                title: const Text('Chọn ngày kết thúc', style: TextStyle(color: AppColors.titleColor)),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    tempEndDate = await _selectDate(context);
                    if (tempEndDate != null) {
                      setState(() {
                        tempEndDate = tempEndDate;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Hủy', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                if (tempStartDate != null && tempEndDate != null) {
                  setState(() {
                    startDate = tempStartDate;
                    endDate = tempEndDate;
                    selectedDate = 'Tùy chỉnh';
                    widget.onDateSelected(startDate, endDate);
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Áp dụng', style: TextStyle(color: Colors.blueAccent)),
            ),
          ],
        );
      },
    );
  }

  Future<DateTime?> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.blueAccent,
            hintColor: Colors.blueAccent,
            colorScheme: const ColorScheme.light(
              primary: Colors.blueAccent,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    return picked;
  }
}
