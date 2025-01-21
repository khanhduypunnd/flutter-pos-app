import 'package:flutter/material.dart';
import '../../../../../../shared/core/theme/colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TimeSelection(),
    );
  }
}

class TimeSelection extends StatefulWidget {
  const TimeSelection({super.key});

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
    switch (value) {
      case 'Hôm nay':
        setState(() {
          startDate = now;
          endDate = now;
        });
        break;
      case 'Ngày hôm qua':
        setState(() {
          startDate = now.subtract(Duration(days: 1));
          endDate = now.subtract(Duration(days: 1));
        });
        break;
      case '7 ngày trước':
        setState(() {
          startDate = now.subtract(Duration(days: 7));
          endDate = now.subtract(Duration(days: 1));
        });
        break;
      case 'Tháng này':
        setState(() {
          startDate = DateTime(now.year, now.month, 1);
          endDate = DateTime(now.year, now.month + 1, 0); // End of the current month
        });
        break;
      case 'Tháng trước':
        setState(() {
          startDate = DateTime(now.year, now.month - 1, 1);
          endDate = DateTime(now.year, now.month, 0); // End of the previous month
        });
        break;
      case 'Tùy chỉnh':
        _showCustomDatePicker(context); // Hiển thị popup tùy chỉnh
        break;
      default:
        setState(() {
          startDate = now;
          endDate = now;
        });
    }
  }

  // Hiển thị popup tùy chỉnh chọn ngày
  Future<void> _showCustomDatePicker(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        DateTime? tempStartDate;
        DateTime? tempEndDate;

        return AlertDialog(
          title: const Text('Chọn khoảng thời gian'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Chọn ngày bắt đầu
              ListTile(
                title: const Text('Chọn ngày bắt đầu'),
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
              // Chọn ngày kết thúc
              ListTile(
                title: const Text('Chọn ngày kết thúc'),
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
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                if (tempStartDate != null && tempEndDate != null) {
                  setState(() {
                    startDate = tempStartDate;
                    endDate = tempEndDate;
                    selectedDate = 'Tùy chỉnh';
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Áp dụng'),
            ),
          ],
        );
      },
    );
  }

  // Chọn một ngày
  Future<DateTime?> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    return picked;
  }
}
