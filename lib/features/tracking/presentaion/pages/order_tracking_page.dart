// lib/features/tracking/presentation/pages/order_tracking_page.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import '../../../../domain/entities/order.dart';

/// Order tracking page with Google Maps integration
class OrderTrackingPage extends StatefulWidget {
  final Order order;

  const OrderTrackingPage({Key? key, required this.order}) : super(key: key);

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  bool _isLoading = true;
  StreamSubscription<Position>? _positionStreamSubscription;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  /// Initialize map with markers and tracking
  Future<void> _initializeMap() async {
    try {
      // Check location permissions
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final requestedPermission = await Geolocator.requestPermission();
        if (requestedPermission == LocationPermission.denied ||
            requestedPermission == LocationPermission.deniedForever) {
          setState(() => _isLoading = false);
          _showPermissionDialog();
          return;
        }
      }

      // Get current position (from order data or default)
      if (widget.order.currentLocation != null) {
        _currentPosition = Position(
          latitude: widget.order.currentLocation!.latitude,
          longitude: widget.order.currentLocation!.longitude,
          timestamp: widget.order.currentLocation!.timestamp,
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );
      } else {
        // Use default position (Negombo, Sri Lanka)
        _currentPosition = Position(
          latitude: 6.9271,
          longitude: 79.8612,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );
      }

      _setupMarkers();
      _setupPolyline();

      setState(() => _isLoading = false);

      // Start simulated tracking
      _startLocationTracking();
    } catch (e) {
      print('Error initializing map: $e');
      setState(() => _isLoading = false);
    }
  }

  /// Setup markers for current location and destination
  void _setupMarkers() {
    if (_currentPosition == null) return;

    // Current location marker (delivery vehicle)
    _markers.add(
      Marker(
        markerId: const MarkerId('current_location'),
        position: LatLng(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(
          title: 'Current Location',
          snippet: 'Delivery in progress',
        ),
      ),
    );

    // Destination marker (simulated - offset from current location)
    final destinationLat = _currentPosition!.latitude + 0.05;
    final destinationLng = _currentPosition!.longitude + 0.05;

    _markers.add(
      Marker(
        markerId: const MarkerId('destination'),
        position: LatLng(destinationLat, destinationLng),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
          title: 'Delivery Address',
          snippet: widget.order.deliveryAddress,
        ),
      ),
    );
  }

  /// Setup polyline to show route
  void _setupPolyline() {
    if (_currentPosition == null) return;

    final destinationLat = _currentPosition!.latitude + 0.05;
    final destinationLng = _currentPosition!.longitude + 0.05;

    _polylines.add(
      Polyline(
        polylineId: const PolylineId('route'),
        points: [
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          LatLng(destinationLat, destinationLng),
        ],
        color: const Color(0xFF2196F3),
        width: 4,
        patterns: [PatternItem.dash(20), PatternItem.gap(10)],
      ),
    );
  }

  /// Start simulated location tracking
  void _startLocationTracking() {
    // Simulate movement every 5 seconds
    _positionStreamSubscription = Stream.periodic(
      const Duration(seconds: 5),
      (count) => count,
    ).listen((count) {
      if (_currentPosition != null && mounted) {
        // Simulate movement towards destination
        final newLat = _currentPosition!.latitude + (0.001 * count);
        final newLng = _currentPosition!.longitude + (0.001 * count);

        setState(() {
          _currentPosition = Position(
            latitude: newLat,
            longitude: newLng,
            timestamp: DateTime.now(),
            accuracy: 0,
            altitude: 0,
            heading: 0,
            speed: 0,
            speedAccuracy: 0,
            altitudeAccuracy: 0,
            headingAccuracy: 0,
          );

          // Update marker
          _markers.removeWhere((m) => m.markerId.value == 'current_location');
          _markers.add(
            Marker(
              markerId: const MarkerId('current_location'),
              position: LatLng(newLat, newLng),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueBlue,
              ),
              infoWindow: const InfoWindow(
                title: 'Current Location',
                snippet: 'Delivery in progress',
              ),
            ),
          );

          // Update polyline
          _polylines.clear();
          _setupPolyline();
        });

        // Animate camera to new position
        _mapController?.animateCamera(
          CameraUpdate.newLatLng(LatLng(newLat, newLng)),
        );
      }
    }) as StreamSubscription<Position>?;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Order'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _centerMapOnCurrentLocation,
            tooltip: 'Center on current location',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentPosition == null
              ? _buildNoLocationView()
              : Column(
                  children: [
                    // Map
                    Expanded(
                      flex: 3,
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(
                            _currentPosition!.latitude,
                            _currentPosition!.longitude,
                          ),
                          zoom: 13,
                        ),
                        markers: _markers,
                        polylines: _polylines,
                        myLocationEnabled: true,
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: false,
                        mapType: MapType.normal,
                        onMapCreated: (controller) {
                          _mapController = controller;
                        },
                      ),
                    ),
                    
                    // Order info card
                    Expanded(
                      flex: 1,
                      child: _buildOrderInfoCard(),
                    ),
                  ],
                ),
    );
  }

  /// Build no location available view
  Widget _buildNoLocationView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.location_off,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'Location data not available',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please enable location services',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _initializeMap,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  /// Build order information card at bottom
  Widget _buildOrderInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getStatusColor(widget.order.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getStatusIcon(widget.order.status),
                  color: _getStatusColor(widget.order.status),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${widget.order.id.substring(0, 8).toUpperCase()}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _getStatusLabel(widget.order.status),
                      style: TextStyle(
                        fontSize: 14,
                        color: _getStatusColor(widget.order.status),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.person, size: 18, color: Colors.grey),
              const SizedBox(width: 8),
              Text(widget.order.customerName),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on, size: 18, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.order.deliveryAddress,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Center map on current location
  void _centerMapOnCurrentLocation() {
    if (_currentPosition != null && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
            ),
            zoom: 15,
          ),
        ),
      );
    }
  }

  /// Show permission dialog
  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Permission Required'),
        content: const Text(
          'This feature requires location permission to track your order. '
          'Please grant location access in your device settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await Geolocator.openLocationSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.processing:
        return Colors.blue;
      case OrderStatus.shipped:
        return Colors.purple;
      case OrderStatus.inTransit:
        return Colors.indigo;
      case OrderStatus.outForDelivery:
        return Colors.teal;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.pending_actions;
      case OrderStatus.processing:
        return Icons.settings;
      case OrderStatus.shipped:
        return Icons.local_shipping;
      case OrderStatus.inTransit:
        return Icons.airport_shuttle;
      case OrderStatus.outForDelivery:
        return Icons.delivery_dining;
      case OrderStatus.delivered:
        return Icons.check_circle;
      case OrderStatus.cancelled:
        return Icons.cancel;
    }
  }

  String _getStatusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.inTransit:
        return 'In Transit';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}