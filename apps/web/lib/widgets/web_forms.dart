import 'package:flutter/material.dart';

/// 📝 **Web Form Components**
/// 
/// Enhanced form components optimized for web input
class WebFormField extends StatefulWidget {
  final String label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? Function(String?)? validator;
  final bool enabled;
  final int? maxLines;
  final int? maxLength;
  final bool showCounter;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;

  const WebFormField({
    super.key,
    required this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.showCounter = false,
    this.focusNode,
    this.textInputAction,
  });

  @override
  State<WebFormField> createState() => _WebFormFieldState();
}

class _WebFormFieldState extends State<WebFormField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: _isFocused
                ? Theme.of(context).primaryColor
                : Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          keyboardType: widget.keyboardType,
          obscureText: widget.obscureText,
          onTap: widget.onTap,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          validator: widget.validator,
          enabled: widget.enabled,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          textInputAction: widget.textInputAction,
          decoration: InputDecoration(
            hintText: widget.hint,
            helperText: widget.helperText,
            errorText: widget.errorText,
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.suffixIcon,
            counterText: widget.showCounter ? null : '',
            filled: true,
            fillColor: widget.enabled
                ? Theme.of(context).cardColor
                : Theme.of(context).disabledColor.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).dividerColor,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).dividerColor,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
                width: 2,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }
}

/// Search field with web optimizations
class WebSearchField extends StatefulWidget {
  final String? hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final TextEditingController? controller;
  final bool showClearButton;
  final bool autofocus;

  const WebSearchField({
    super.key,
    this.hint,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.controller,
    this.showClearButton = true,
    this.autofocus = false,
  });

  @override
  State<WebSearchField> createState() => _WebSearchFieldState();
}

class _WebSearchFieldState extends State<WebSearchField> {
  late TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _hasText = _controller.text.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: TextField(
        controller: _controller,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        autofocus: widget.autofocus,
        decoration: InputDecoration(
          hintText: widget.hint ?? 'Search...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _hasText && widget.showClearButton
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                    widget.onClear?.call();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}

/// Multi-select dropdown
class WebMultiSelect<T> extends StatefulWidget {
  final String label;
  final List<MultiSelectItem<T>> items;
  final List<T> selectedValues;
  final ValueChanged<List<T>>? onChanged;
  final String? hint;
  final bool enabled;
  final String? errorText;

  const WebMultiSelect({
    super.key,
    required this.label,
    required this.items,
    required this.selectedValues,
    this.onChanged,
    this.hint,
    this.enabled = true,
    this.errorText,
  });

  @override
  State<WebMultiSelect<T>> createState() => _WebMultiSelectState<T>();
}

class _WebMultiSelectState<T> extends State<WebMultiSelect<T>> {
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: widget.enabled ? _toggleDropdown : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: widget.enabled
                  ? Theme.of(context).cardColor
                  : Theme.of(context).disabledColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.errorText != null
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).dividerColor,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: widget.selectedValues.isEmpty
                      ? Text(
                          widget.hint ?? 'Select items...',
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                          ),
                        )
                      : Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: widget.selectedValues.map((value) {
                            final item = widget.items.firstWhere(
                              (item) => item.value == value,
                            );
                            return Chip(
                              label: Text(item.label),
                              onDeleted: () {
                                final newValues = List<T>.from(widget.selectedValues);
                                newValues.remove(value);
                                widget.onChanged?.call(newValues);
                              },
                              deleteIcon: const Icon(Icons.close, size: 16),
                            );
                          }).toList(),
                        ),
                ),
                Icon(
                  _isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: Theme.of(context).iconTheme.color,
                ),
              ],
            ),
          ),
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.errorText!,
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontSize: 12,
            ),
          ),
        ],
        if (_isOpen)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).dividerColor,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: widget.items.map((item) {
                final isSelected = widget.selectedValues.contains(item.value);
                return InkWell(
                  onTap: () {
                    final newValues = List<T>.from(widget.selectedValues);
                    if (isSelected) {
                      newValues.remove(item.value);
                    } else {
                      newValues.add(item.value);
                    }
                    widget.onChanged?.call(newValues);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Checkbox(
                          value: isSelected,
                          onChanged: (value) {
                            final newValues = List<T>.from(widget.selectedValues);
                            if (value == true) {
                              newValues.add(item.value);
                            } else {
                              newValues.remove(item.value);
                            }
                            widget.onChanged?.call(newValues);
                          },
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Text(item.label)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  void _toggleDropdown() {
    setState(() {
      _isOpen = !_isOpen;
    });
  }
}

/// Multi-select item model
class MultiSelectItem<T> {
  final T value;
  final String label;
  final String? description;

  const MultiSelectItem({
    required this.value,
    required this.label,
    this.description,
  });
}

/// Date range picker
class WebDateRangePicker extends StatefulWidget {
  final String label;
  final DateTimeRange? selectedRange;
  final ValueChanged<DateTimeRange>? onChanged;
  final String? errorText;
  final bool enabled;

  const WebDateRangePicker({
    super.key,
    required this.label,
    this.selectedRange,
    this.onChanged,
    this.errorText,
    this.enabled = true,
  });

  @override
  State<WebDateRangePicker> createState() => _WebDateRangePickerState();
}

class _WebDateRangePickerState extends State<WebDateRangePicker> {
  Future<void> _selectDateRange() async {
    if (!widget.enabled) return;

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: widget.selectedRange,
    );

    if (picked != null && picked != widget.selectedRange) {
      widget.onChanged?.call(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _selectDateRange,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: widget.enabled
                  ? Theme.of(context).cardColor
                  : Theme.of(context).disabledColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.errorText != null
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).dividerColor,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.date_range),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.selectedRange != null
                        ? '${_formatDate(widget.selectedRange!.start)} - ${_formatDate(widget.selectedRange!.end)}'
                        : 'Select date range',
                    style: TextStyle(
                      color: widget.selectedRange != null
                          ? Theme.of(context).textTheme.bodyMedium?.color
                          : Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                    ),
                  ),
                ),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.errorText!,
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
