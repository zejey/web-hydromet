import 'package:flutter/material.dart';
import '../models/notification.dart';
import 'package:intl/intl.dart';
import '../widgets/admin_drawer.dart';
import '../services/notification_service.dart';
import 'package:go_router/go_router.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationAlert> _alerts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map && args['showAddAlert'] == true) {
        setState(() {
          _showForm = true;
        });
      }
    });
  }

  Future<void> _fetchNotifications() async {
    setState(() => _isLoading = true);
    _alerts = await NotificationService.instance.getNotifications();
    _removeOldAlerts();
    setState(() => _isLoading = false);
  }

  void _removeOldAlerts() {
    final now = DateTime.now();
    setState(() {
      _alerts.removeWhere(
        (alert) => now.difference(alert.dateTime).inDays > 14,
      );
    });
  }

  void _onDrawerItemSelected(int index) {
    if (index == 2) return; // Already on Post Notification
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/users');
        break;
      case 3:
        context.go('/settings');
        break;
      case 4:
        context.go('/system-logs');
        break;
    }
  }

  void _onLogout() {
    context.go('/login');
  }

  final _formKey = GlobalKey<FormState>();
  String? _alertType;
  String _alertTitle = '';
  String _alertMessage = '';
  bool _isEditing = false;
  NotificationAlert? _editingAlert;
  bool _showForm = false;

  void _resetForm() {
    setState(() {
      _formKey.currentState?.reset();
      _alertType = null;
      _alertTitle = '';
      _alertMessage = '';
      _isEditing = false;
      _editingAlert = null;
      _showForm = false;
    });
  }

  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      final alertMessage = _alertMessage.trim();
      if (alertMessage.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter alert message')),
        );
        return;
      }
      if (_isEditing && _editingAlert != null) {
        final updatedAlert = NotificationAlert(
          id: _editingAlert!.id,
          type: _alertType!,
          title: _alertTitle,
          message: alertMessage,
          dateTime: DateTime.now(),
          status: _editingAlert!.status,
          sentTo: _editingAlert!.sentTo,
        );
        await NotificationService.instance.updateNotification(
          updatedAlert.id,
          updatedAlert,
        );
      } else {
        final newAlert = NotificationAlert(
          id: '', // let Firestore generate it
          type: _alertType!,
          title: _alertTitle,
          message: alertMessage,
          dateTime: DateTime.now(),
          status: 'Active',
          sentTo: 0,
        );
        await NotificationService.instance.addNotification(newAlert);
      }
      await _fetchNotifications();
      setState(() {
        _showForm = false;
      });
      _resetForm();
    }
  }

  void _editAlert(NotificationAlert alert) {
    setState(() {
      _isEditing = true;
      _editingAlert = alert;
      _alertType = alert.type;
      _alertTitle = alert.title;
      _alertMessage = alert.message;
      _showForm = true;
    });
  }

  void _deleteAlert(NotificationAlert alert) async {
    await NotificationService.instance.deleteNotification(alert.id);
    await _fetchNotifications();
  }

  Widget _buildTypeBadge(String type) {
    Color color;
    IconData icon;
    switch (type) {
      case 'Emergency':
        color = Colors.red;
        icon = Icons.priority_high_rounded;
        break;
      case 'Warning':
        color = Colors.orange;
        icon = Icons.warning_amber_rounded;
        break;
      default:
        color = Colors.blue;
        icon = Icons.info_rounded;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            type,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = status == 'Active' ? Colors.green : Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
    return Scaffold(
      drawer: AdminDrawer(
        selectedIndex: 2,
        onItemSelected: _onDrawerItemSelected,
        onLogout: _onLogout,
      ),
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.notifications_active_rounded, color: Colors.white),
            SizedBox(width: 10),
            Text(
              'Post Notification',
              style: TextStyle(fontWeight: FontWeight.normal),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2d5f3f),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: Center(
              child: Text(
                'Welcome, CDRRMO',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
        elevation: 6,
        shadowColor: Colors.black.withOpacity(0.2),
      ),
      backgroundColor: const Color(0xFFf6fbf7),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_showForm)
                        Expanded(
                          flex: 2,
                          child: Card(
                            elevation: 8,
                            shadowColor: Colors.green.withOpacity(0.15),
                            color: const Color(0xFFf6fbf7),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(bottom: 8.0),
                                      child: Text(
                                        'Reminders: Notifications older than 14 days will be automatically deleted.',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.redAccent,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: const [
                                        Icon(
                                          Icons.add_alert_rounded,
                                          color: Color(0xFF13b464),
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Create New Alert',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 19,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 18),
                                    DropdownButtonFormField<String>(
                                      value: _alertType,
                                      decoration: const InputDecoration(
                                        labelText: 'Alert Type *',
                                        prefixIcon: Icon(
                                          Icons.priority_high_rounded,
                                        ),
                                        helperText:
                                            'Select the urgency level of your alert',
                                        filled: true,
                                        fillColor: Color(0xFFeafaf3),
                                      ),
                                      items: const [
                                        DropdownMenuItem(
                                          value: 'Emergency',
                                          child: Text('Emergency'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'Warning',
                                          child: Text('Warning'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'Info',
                                          child: Text('Info'),
                                        ),
                                      ],
                                      validator: (v) => v == null
                                          ? 'Please select alert type'
                                          : null,
                                      onChanged: (v) =>
                                          setState(() => _alertType = v),
                                      onSaved: (v) => _alertType = v,
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      initialValue: _alertTitle,
                                      maxLength: 100,
                                      decoration: const InputDecoration(
                                        labelText: 'Alert Title *',
                                        prefixIcon: Icon(Icons.title),
                                        helperText: 'Maximum 100 characters',
                                        filled: true,
                                        fillColor: Color(0xFFeafaf3),
                                      ),
                                      validator: (v) =>
                                          (v == null || v.trim().isEmpty)
                                              ? 'Please enter alert title'
                                              : null,
                                      onChanged: (v) =>
                                          setState(() => _alertTitle = v),
                                      onSaved: (v) => _alertTitle = v ?? '',
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Alert Message *',
                                      style: TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      initialValue: _alertMessage,
                                      maxLines: 7,
                                      maxLength: 1000,
                                      decoration: const InputDecoration(
                                        labelText: 'Alert Message',
                                        alignLabelWithHint: true,
                                        prefixIcon: Icon(Icons.message),
                                        filled: true,
                                        fillColor: Color(0xFFeafaf3),
                                      ),
                                      validator: (v) =>
                                          (v == null || v.trim().isEmpty)
                                              ? 'Please enter alert message'
                                              : null,
                                      onChanged: (v) =>
                                          setState(() => _alertMessage = v),
                                      onSaved: (v) => _alertMessage = v ?? '',
                                    ),
                                    const SizedBox(height: 18),
                                    Row(
                                      children: [
                                        ElevatedButton.icon(
                                          icon: const Icon(Icons.send),
                                          label: Text(
                                            _isEditing
                                                ? 'Update Alert'
                                                : 'Send Alert',
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFFFFA726,
                                            ),
                                            foregroundColor: Colors.white,
                                            minimumSize: const Size(140, 48),
                                            elevation: 2,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(
                                                8,
                                              ),
                                            ),
                                          ),
                                          onPressed: _submitForm,
                                        ),
                                        const SizedBox(width: 16),
                                        TextButton.icon(
                                          icon: const Icon(Icons.clear),
                                          label: const Text('Clear Form'),
                                          onPressed: _resetForm,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (_showForm)
                        const VerticalDivider(
                          width: 32,
                          thickness: 1,
                          color: Color(0xFFe0e0e0),
                        ),
                      // Alert History
                      Expanded(
                        flex: 3,
                        child: Card(
                          elevation: 8,
                          shadowColor: Colors.green.withOpacity(0.15),
                          color: const Color(0xFFf6fbf7),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: const [
                                        Icon(
                                          Icons.history_edu_rounded,
                                          color: Color(0xFF13b464),
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Alert History',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 19,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.orange.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            '${_alerts.length} alerts',
                                            style: const TextStyle(
                                              color: Colors.orange,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        if (!_showForm)
                                          ElevatedButton.icon(
                                            icon: const Icon(
                                              Icons.add_alert_rounded,
                                              color: Colors.white,
                                            ),
                                            label: const Text(
                                              'Create Alert',
                                              style: TextStyle(color: Colors.white),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Color(0xFFFFA726),
                                              foregroundColor: Colors.white,
                                              elevation: 2,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(
                                                  8,
                                                ),
                                              ),
                                            ),
                                            onPressed: () =>
                                                setState(() => _showForm = true),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF13b464),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    child: Row(
                                      children: const [
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            'Title',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Center(
                                            child: Text(
                                              'Type',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Center(
                                            child: Text(
                                              'Sent To',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Center(
                                            child: Text(
                                              'Actions',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                ..._alerts.map(
                                  (alert) => MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 180),
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.green.withOpacity(0.07),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                        border: Border(
                                          bottom: BorderSide(
                                            color: Colors.grey.shade200,
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 12,
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    alert.title,
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  Text(
                                                    DateFormat(
                                                      'yyyy-MM-dd hh:mm a',
                                                    ).format(alert.dateTime),
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Center(
                                                child: _buildTypeBadge(alert.type),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Center(
                                                child: Text(
                                                  '${alert.sentTo} users',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Center(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Tooltip(
                                                      message: 'Edit this alert',
                                                      child: IconButton(
                                                        icon: const Icon(
                                                          Icons.edit,
                                                          color: Colors.blue,
                                                        ),
                                                        tooltip: 'Edit',
                                                        onPressed: () =>
                                                            _editAlert(alert),
                                                      ),
                                                    ),
                                                    Tooltip(
                                                      message: 'Delete this alert',
                                                      child: IconButton(
                                                        icon: const Icon(
                                                          Icons.delete,
                                                          color: Colors.red,
                                                        ),
                                                        tooltip: 'Delete',
                                                        onPressed: () =>
                                                            _deleteAlert(alert),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : ListView(
                    children: [
                      if (_showForm)
                        Card(
                          elevation: 4,
                          color: const Color(0xFFf6fbf7),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Create New Alert',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  DropdownButtonFormField<String>(
                                    value: _alertType,
                                    decoration: const InputDecoration(
                                      labelText: 'Alert Type *',
                                      prefixIcon: Icon(Icons.priority_high_rounded),
                                      helperText:
                                          'Select the urgency level of your alert',
                                      filled: true,
                                      fillColor: Color(0xFFeafaf3),
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'Emergency',
                                        child: Text('Emergency'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Warning',
                                        child: Text('Warning'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Info',
                                        child: Text('Info'),
                                      ),
                                    ],
                                    validator: (v) => v == null
                                        ? 'Please select alert type'
                                        : null,
                                    onChanged: (v) =>
                                        setState(() => _alertType = v),
                                    onSaved: (v) => _alertType = v,
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    initialValue: _alertTitle,
                                    maxLength: 100,
                                    decoration: const InputDecoration(
                                      labelText: 'Alert Title *',
                                      prefixIcon: Icon(Icons.title),
                                      helperText: 'Maximum 100 characters',
                                      filled: true,
                                      fillColor: Color(0xFFeafaf3),
                                    ),
                                    validator: (v) =>
                                        (v == null || v.trim().isEmpty)
                                        ? 'Please enter alert title'
                                        : null,
                                    onChanged: (v) =>
                                        setState(() => _alertTitle = v),
                                    onSaved: (v) => _alertTitle = v ?? '',
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Alert Message *',
                                    style: TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    height: 180,
                                    decoration: BoxDecoration(
                                      color: Color(0xFFeafaf3),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.grey),
                                    ),
                                    child: TextFormField(
                                      initialValue: _alertMessage,
                                      maxLines: 7,
                                      maxLength: 1000,
                                      decoration: const InputDecoration(
                                        labelText: 'Alert Message',
                                        alignLabelWithHint: true,
                                        prefixIcon: Icon(Icons.message),
                                        filled: true,
                                        fillColor: Color(0xFFeafaf3),
                                      ),
                                      validator: (v) =>
                                          (v == null || v.trim().isEmpty)
                                          ? 'Please enter alert message'
                                          : null,
                                      onChanged: (v) =>
                                          setState(() => _alertMessage = v),
                                      onSaved: (v) => _alertMessage = v ?? '',
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  Row(
                                    children: [
                                      ElevatedButton.icon(
                                        icon: const Icon(Icons.send),
                                        label: Text(
                                          _isEditing
                                              ? 'Update Alert'
                                              : 'Send Alert',
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFFFFA726),
                                          foregroundColor: Colors.white,
                                          minimumSize: const Size(140, 48),
                                          elevation: 2,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        onPressed: _submitForm,
                                      ),
                                      const SizedBox(width: 16),
                                      TextButton.icon(
                                        icon: const Icon(Icons.clear),
                                        label: const Text('Clear Form'),
                                        onPressed: _resetForm,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),
                      Card(
                        elevation: 4,
                        color: const Color(0xFFf6fbf7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Alert History',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          '${_alerts.length} alerts',
                                          style: const TextStyle(
                                            color: Colors.orange,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      if (!_showForm)
                                        ElevatedButton.icon(
                                          icon: const Icon(
                                            Icons.add_alert_rounded,
                                            color: Colors.white,
                                          ),
                                          label: const Text(
                                            'Create Alert',
                                            style: TextStyle(color: Colors.white),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Color(0xFFFFA726),
                                            foregroundColor: Colors.white,
                                            elevation: 2,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(
                                                8,
                                              ),
                                            ),
                                          ),
                                          onPressed: () =>
                                              setState(() => _showForm = true),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF13b464),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  child: Row(
                                    children: const [
                                      Expanded(
                                        child: Text(
                                          'Title',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      SizedBox(
                                        width: 90,
                                        child: Text(
                                          'Type',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 80,
                                        child: Text(
                                          'Status',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 80,
                                        child: Text(
                                          'Sent To',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 120,
                                        child: Text(
                                          'Actions',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Alert list items
                              ..._alerts.map(
                                (alert) => Container(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.grey.shade200,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                alert.title,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                DateFormat(
                                                  'yyyy-MM-dd hh:mm a',
                                                ).format(alert.dateTime),
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        SizedBox(
                                          width: 90,
                                          child: _buildTypeBadge(alert.type),
                                        ),
                                        SizedBox(
                                          width: 80,
                                          child: _buildStatusBadge(alert.status),
                                        ),
                                        SizedBox(
                                          width: 80,
                                          child: Text('${alert.sentTo} users'),
                                        ),
                                        SizedBox(
                                          width: 120,
                                          child: Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.edit,
                                                  color: Colors.blue,
                                                ),
                                                tooltip: 'Edit',
                                                onPressed: () => _editAlert(alert),
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                ),
                                                tooltip: 'Delete',
                                                onPressed: () =>
                                                    _deleteAlert(alert),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ).toList(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
