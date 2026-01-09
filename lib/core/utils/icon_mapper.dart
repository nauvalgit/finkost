import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';

class IconMapper {
  static const Map<String, IconData> _iconMap = {
    
    'utensils': FontAwesomeIcons.utensils,
    'burger': FontAwesomeIcons.burger,
    'coffee': FontAwesomeIcons.coffee,
    'pizzaSlice': FontAwesomeIcons.pizzaSlice,
    'appleWhole': FontAwesomeIcons.appleWhole,
    'cookieBite': FontAwesomeIcons.cookieBite,
    'bowlFood': FontAwesomeIcons.bowlFood,
    'iceCream': FontAwesomeIcons.iceCream,

    
    'car': FontAwesomeIcons.car,
    'plane': FontAwesomeIcons.plane,
    'bus': FontAwesomeIcons.bus,
    'train': FontAwesomeIcons.train,
    'motorcycle': FontAwesomeIcons.motorcycle,
    'bicycle': FontAwesomeIcons.bicycle,
    'taxi': FontAwesomeIcons.taxi,
    'ship': FontAwesomeIcons.ship,

    
    'bagShopping': FontAwesomeIcons.bagShopping,
    'cartShopping': FontAwesomeIcons.cartShopping,
    'shirt': FontAwesomeIcons.shirt,
    'tag': FontAwesomeIcons.tag,
    'gem': FontAwesomeIcons.gem,
    'gift': FontAwesomeIcons.gift,
    'store': FontAwesomeIcons.store,
    'receipt': FontAwesomeIcons.receipt,

    
    'film': FontAwesomeIcons.film,
    'gamepad': FontAwesomeIcons.gamepad,
    'book': FontAwesomeIcons.book,
    'music': FontAwesomeIcons.music,
    'camera': FontAwesomeIcons.camera,
    'heart': FontAwesomeIcons.heart, 
    'campground': FontAwesomeIcons.campground,
    'ticket': FontAwesomeIcons.ticket,

    
    'graduationCap': FontAwesomeIcons.graduationCap,
    'bookOpen': FontAwesomeIcons.bookOpen,
    'laptopCode': FontAwesomeIcons.laptopCode,
    'pencil': FontAwesomeIcons.pencil,

    
    'hospital': FontAwesomeIcons.hospital,
    'medkit': FontAwesomeIcons.medkit,
    'handHoldingMedical': FontAwesomeIcons.handHoldingMedical,
    'dumbbell': FontAwesomeIcons.dumbbell,
    'heartbeat': FontAwesomeIcons.heartbeat,

    
    'house': FontAwesomeIcons.house,
    'lightbulb': FontAwesomeIcons.lightbulb,
    'wifi': FontAwesomeIcons.wifi,
    'water': FontAwesomeIcons.water,
    'gasPump': FontAwesomeIcons.gasPump,
    'wrench': FontAwesomeIcons.wrench, 
    'couch': FontAwesomeIcons.couch, 

    
    'wallet': FontAwesomeIcons.wallet,
    'sackDollar': FontAwesomeIcons.sackDollar,
    'moneyBillWave': FontAwesomeIcons.moneyBillWave,
    'chartLine': FontAwesomeIcons.chartLine,
    'piggyBank': FontAwesomeIcons.piggyBank,
    'creditCard': FontAwesomeIcons.creditCard,

    
    'question': FontAwesomeIcons.question,
    'ellipsisH': FontAwesomeIcons.ellipsisH,
    'globe': FontAwesomeIcons.globe,
    'phone': FontAwesomeIcons.phone,
    'desktop': FontAwesomeIcons.desktop,
    'toolbox': FontAwesomeIcons.toolbox,
    'building': FontAwesomeIcons.building, 
    'handshake': FontAwesomeIcons.handshake, 
    'rocket': FontAwesomeIcons.rocket, 
    'cloud': FontAwesomeIcons.cloud, 

    'paw': FontAwesomeIcons.paw, 
    'baby': FontAwesomeIcons.baby, 
  };

  static const Map<String, List<String>> groupedIcons = {
    "Makanan & Minuman": [
      'utensils', 'burger', 'coffee', 'pizzaSlice', 'appleWhole', 'cookieBite', 'bowlFood', 'iceCream'
    ],
    "Transportasi": [
      'car', 'plane', 'bus', 'train', 'motorcycle', 'bicycle', 'taxi', 'ship'
    ],
    "Belanja": [
      'bagShopping', 'cartShopping', 'shirt', 'tag', 'gem', 'gift', 'store', 'receipt'
    ],
    "Hiburan & Rekreasi": [
      'film', 'gamepad', 'book', 'music', 'camera', 'heart', 'campground', 'ticket'
    ],
    "Pendidikan": [
      'graduationCap', 'bookOpen', 'laptopCode', 'pencil'
    ],
    "Kesehatan & Kebugaran": [
      'hospital', 'medkit', 'handHoldingMedical', 'dumbbell', 'heartbeat'
    ],
    "Rumah & Tagihan": [
      'house', 'lightbulb', 'wifi', 'water', 'gasPump', 'wrench', 'couch'
    ],
    "Keuangan & Investasi": [
      'wallet', 'sackDollar', 'moneyBillWave', 'chartLine', 'piggyBank', 'creditCard'
    ],
    "Lain-lain": [
      
      'question', 'ellipsisH', 'globe', 'phone', 'desktop', 'toolbox', 'building',
      'handshake', 'rocket', 'cloud', 'paw', 'baby'
    ],
  };

  static IconData mapStringToIconData(String? iconName) {
    if (iconName != null && _iconMap.containsKey(iconName)) {
      return _iconMap[iconName]!;
    }
    return FontAwesomeIcons.circleQuestion; 
  }
}