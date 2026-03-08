import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/sale.dart';
import '../models/sale_item.dart';
import '../services/db_helper.dart';
import 'package:intl/intl.dart';

class ReportsScreen extends StatefulWidget {
  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _filter = 'Diario';
  List<Sale> _sales = [];
  double _totalAmount = 0;
  bool _isLoading = true;
  
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadSales();
  }

  void _setDateRange(String filter) {
    final now = DateTime.now();
    _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);

    if (filter == 'Diario') {
      _startDate = DateTime(now.year, now.month, now.day);
    } else if (filter == 'Semanal') {
      _startDate = now.subtract(Duration(days: now.weekday - 1));
      _startDate = DateTime(_startDate.year, _startDate.month, _startDate.day);
    } else if (filter == 'Mensual') {
      _startDate = DateTime(now.year, now.month, 1);
    }
  }

  Future<void> _loadSales() async {
    setState(() => _isLoading = true);
    
    if (_filter != 'Personalizado') {
      _setDateRange(_filter);
    }

    _sales = await DatabaseHelper.instance.getSalesByDateRange(_startDate, _endDate);
    _totalAmount = _sales.fold(0, (sum, sale) => sum + sale.totalAmount);

    setState(() => _isLoading = false);
  }

  Future<void> _pickDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      saveText: "Aplicar",
    );
    
    if (picked != null) {
      setState(() {
        _filter = 'Personalizado';
        _startDate = DateTime(picked.start.year, picked.start.month, picked.start.day);
        _endDate = DateTime(picked.end.year, picked.end.month, picked.end.day, 23, 59, 59);
      });
      _loadSales();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reporte de Ventas')),
      body: Column(
        children: [
           Padding(
             padding: const EdgeInsets.all(8.0),
             child: SingleChildScrollView(
               scrollDirection: Axis.horizontal,
               child: Row(
                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                 children: ['Diario', 'Semanal', 'Mensual', 'Personalizado'].map((String filter) {
                   return Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 4.0),
                     child: ChoiceChip(
                       label: Text(filter),
                       selected: _filter == filter,
                       onSelected: (bool selected) {
                         if (selected) {
                           if (filter == 'Personalizado') {
                             _pickDateRange();
                           } else {
                             setState(() => _filter = filter);
                             _loadSales();
                           }
                         }
                       },
                     ),
                   );
                 }).toList(),
               ),
             ),
           ),
           if (_filter == 'Personalizado')
             Text(
               '${DateFormat('dd/MM/yyyy').format(_startDate)} - ${DateFormat('dd/MM/yyyy').format(_endDate)}',
               style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
             ),
           
           Container(
             margin: EdgeInsets.all(16),
             padding: EdgeInsets.all(20),
             decoration: BoxDecoration(
               color: Colors.blue.shade800,
               borderRadius: BorderRadius.circular(15),
             ),
             child: Column(
               children: [
                 Text('Ventas Totales', style: TextStyle(color: Colors.white70, fontSize: 16)),
                 SizedBox(height: 8),
                 Text('\$${_totalAmount.toStringAsFixed(2)}', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
               ],
             ),
           ),

           Expanded(
             child: _isLoading 
                ? Center(child: CircularProgressIndicator())
                : _sales.isEmpty 
                  ? Center(child: Text('No hay ventas en este periodo.'))
                  : ListView.builder(
                      itemCount: _sales.length,
                      itemBuilder: (context, index) {
                        final sale = _sales[index];
                        return ListTile(
                          leading: Icon(Icons.monetization_on, color: Colors.green),
                          title: Text(sale.ticketNumber != null 
                            ? 'Comanda #${sale.ticketNumber}' 
                            : 'Venta #${sale.id}'),
                          subtitle: Text(DateFormat('dd/MM/yyyy HH:mm').format(sale.date)),
                          trailing: Text('\$${sale.totalAmount.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          onTap: () => _showSaleDetails(sale),
                        );
                      },
                    ),
           )
        ],
      )
    );
  }

  void _showSaleDetails(Sale sale) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return FutureBuilder<List<SaleItem>>(
          future: DatabaseHelper.instance.getSaleItemsBySaleId(sale.id!),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No hay detalles para esta venta.'));
            }
            final items = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Detalle: ${sale.ticketNumber != null ? 'Comanda #${sale.ticketNumber}' : 'Venta #${sale.id}'}', 
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Divider(),
                  Expanded(
                    child: ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return ListTile(
                          title: Text(item.name),
                          subtitle: Text('${item.quantity} x \$${item.unitPrice.toStringAsFixed(0)}'),
                          trailing: Text('\$${item.subtotal.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.bold)),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text('Total Pagado: \$${sale.totalAmount.toStringAsFixed(0)}', 
                      style: TextStyle(fontSize: 18, color: Colors.green.shade700, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            );
          },
        );
      }
    );
  }
}
