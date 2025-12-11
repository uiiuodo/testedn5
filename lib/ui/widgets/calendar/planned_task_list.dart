import 'package:flutter/material.dart';
import '../../../../data/model/planned_task.dart';

class PlannedTaskList extends StatefulWidget {
  final List<PlannedTask> tasks;
  final Function(String) onAdd;
  final Function(PlannedTask, String) onUpdate;
  final Function(String) onDelete;

  const PlannedTaskList({
    super.key,
    required this.tasks,
    required this.onAdd,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  State<PlannedTaskList> createState() => _PlannedTaskListState();
}

class _PlannedTaskListState extends State<PlannedTaskList> {
  bool _isAdding = false;
  final TextEditingController _addController = TextEditingController();
  final FocusNode _addFocusNode = FocusNode();

  @override
  void dispose() {
    _addController.dispose();
    _addFocusNode.dispose();
    super.dispose();
  }

  void _startAdding() {
    setState(() {
      _isAdding = true;
    });
    // Request focus after rebuild
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _addFocusNode.requestFocus();
    });
  }

  void _cancelAdding() {
    setState(() {
      _isAdding = false;
      _addController.clear();
    });
  }

  void _submitAdd() {
    if (_addController.text.trim().isNotEmpty) {
      widget.onAdd(_addController.text.trim());
    }
    _cancelAdding();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 52.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 9,
                    height: 9,
                    color: const Color(0xFFB0B0B0),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    '계획해야 하는 일정',
                    style: TextStyle(
                      color: Color(0xFF9D9D9D),
                      fontSize: 10,
                      fontFamily: 'Noto Sans',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: _startAdding,
                child: const Icon(
                  Icons.add,
                  size: 16,
                  color: Color(0xFF9D9D9D),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 52.0),
          child: Column(
            children: [
              // List Items
              ...widget.tasks.map((task) => _buildTaskItem(task)),

              // Adding Item Input
              if (_isAdding)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: TextField(
                    controller: _addController,
                    focusNode: _addFocusNode,
                    style: const TextStyle(
                      color: Color(0xFF464646),
                      fontSize: 10,
                      fontFamily: 'Noto Sans',
                      fontWeight: FontWeight.w300,
                      height: 1.5,
                    ),
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                      hintText: '입력 후 완료를 누르세요',
                      hintStyle: TextStyle(
                        color: Color(0xFFB0B0B0),
                        fontSize: 10,
                      ),
                    ),
                    onSubmitted: (_) => _submitAdd(),
                    textInputAction: TextInputAction.done,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTaskItem(PlannedTask task) {
    return _EditableTaskItem(
      key: ValueKey(task.id),
      task: task,
      onUpdate: widget.onUpdate,
      onDelete: widget.onDelete,
    );
  }
}

class _EditableTaskItem extends StatefulWidget {
  final PlannedTask task;
  final Function(PlannedTask, String) onUpdate;
  final Function(String) onDelete;

  const _EditableTaskItem({
    super.key,
    required this.task,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  State<_EditableTaskItem> createState() => _EditableTaskItemState();
}

class _EditableTaskItemState extends State<_EditableTaskItem> {
  bool _isEditing = false;
  bool _showDelete = false;
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.task.content);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
      _showDelete = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  void _submitEdit() {
    if (_controller.text.trim().isNotEmpty &&
        _controller.text.trim() != widget.task.content) {
      widget.onUpdate(widget.task, _controller.text.trim());
    } else if (_controller.text.trim().isEmpty) {
      _controller.text = widget.task.content; // Revert if empty
    }
    setState(() {
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        setState(() {
          _showDelete = true;
        });
      },
      onTap: () {
        if (_showDelete) {
          setState(() {
            _showDelete = false;
          });
        } else if (!_isEditing) {
          _startEditing();
        }
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Row(
          children: [
            Expanded(
              child: _isEditing
                  ? TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      style: const TextStyle(
                        color: Color(0xFF464646),
                        fontSize: 10,
                        fontFamily: 'Noto Sans',
                        fontWeight: FontWeight.w300,
                        height: 1.5,
                      ),
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _submitEdit(),
                      onEditingComplete: _submitEdit,
                      textInputAction: TextInputAction.done,
                    )
                  : Text(
                      widget.task.content,
                      style: const TextStyle(
                        color: Color(0xFF464646),
                        fontSize: 10,
                        fontFamily: 'Noto Sans',
                        fontWeight: FontWeight.w300,
                        height: 1.5,
                      ),
                    ),
            ),
            if (_showDelete)
              GestureDetector(
                onTap: () {
                  widget.onDelete(widget.task.id);
                },
                child: const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Icon(Icons.close, size: 16, color: Color(0xFF9D9D9D)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
