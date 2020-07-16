import 'dart:io';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';

import 'package:qrreaderapp/src/bloc/scans_bloc.dart';
import 'package:qrreaderapp/src/models/scan_model.dart';

import 'package:qrreaderapp/src/pages/mapas_page.dart';
import 'package:qrreaderapp/src/pages/direcciones_page.dart';

import 'package:qrreaderapp/src/utils/utils.dart' as utils;


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final scansBloc = new ScansBloc();
  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Scanner'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete_forever),
            onPressed: scansBloc.borrarScansTODOS,
          )
        ],
      ),
      body: _callPage(currentIndex),
      bottomNavigationBar: _crearBottomNavigationBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.filter_center_focus),
        onPressed: ()=> _scanQR(context),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

    

    _scanQR(BuildContext context) async {

    //https://fernando-herrera.com/#/home
    //geo:40.744004553556984,-74.19957533320316
 
      dynamic futureString = '';
 
     try {
       futureString = await BarcodeScanner.scan();
       if(futureString.rawContent==''){
         futureString.rawContent=null;
       }
     }catch(e){
       futureString=e.toString();
     }

      print('Future String: ${futureString.rawContent}');
       String validador = futureString.rawContent.toString();

      if(validador.contains('geo')||validador.contains('http')){
        if(futureString != null){
          final scan = ScanModel(valor: futureString.rawContent);
          scansBloc.agregarScan(scan);
          if(Platform.isIOS){
            Future.delayed(Duration(milliseconds: 750),(){
              utils.abrirScan(context, scan);
            });
          }else{
            utils.abrirScan(context, scan);
          }
        }
      }else{
         _aviso(context, validador);
      }
    }

  Widget _callPage(int paginaActual){
    switch(paginaActual){
      case 0: return MapasPage();
      case 1: return DireccionesPage();
      default:
        return MapasPage();
    }
  }

  Widget _crearBottomNavigationBar(){
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        setState(() {
          currentIndex = index;
        });
      },
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.map),
          title: Text('Maps')
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.brightness_5),
          title: Text('Direcciones')
        )
      ]
    );
  }

  void _aviso(BuildContext context, String validador){
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('AVISO'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(height: 5.0,),
              Text('QR no soportado'),
              SizedBox(height: 5.0,),
              Text('La información corresponde a:'),
              SizedBox(height: 5.0,),
              Text(validador),
 
            ],
          ),
          actions: <Widget>[
            FlatButton(
              onPressed: ()=>Navigator.of(context).pop(), 
              child: Text('Reintentar',),
              color: Theme.of(context).primaryColor,
              ),
          ],
        );
      },
    );
  }
}