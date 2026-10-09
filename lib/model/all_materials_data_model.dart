import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MaterialCategoryMeta {
  final String name;
  final String slug;
  final String label;
  final String defaultUnit;
  final List<String> subItems;

  const MaterialCategoryMeta({
    required this.name,
    required this.slug,
    required this.label,
    required this.defaultUnit,
    required this.subItems,
  });
}

class AllMaterialsCatalog {
  static const List<String> standardUnits = [
    'Bags',
    'Ton',
    'Kg',
    'Nos',
    'Units',
    'Sq.Ft',
    'Cft',
    'Cum',
    'Coil',
    'Litre',
    'Boxes',
    'Load',
    'Bundles',
    'Pieces',
    'Mtrs',
  ];

  static const List<double> gstRates = [0.0, 5.0, 12.0, 18.0, 28.0];

  static const List<MaterialCategoryMeta> categories = [
    MaterialCategoryMeta(
      name: 'Bricks / Blocks',
      slug: 'bricks',
      label: 'Brick / Block Type',
      defaultUnit: 'Nos',
      subItems: [
        'Red Clay Brick',
        'Fly Ash Bricks',
        'AAC Blocks (Autoclaved Aerated Concrete)',
        'Solid Concrete Blocks',
        'Hollow Concrete Blocks',
        'Wire Cut Bricks',
        'Clay Paver Bricks',
        'Stone / Rubble',
      ],
    ),
    MaterialCategoryMeta(
      name: 'Cement',
      slug: 'cement',
      label: 'Cement Type',
      defaultUnit: 'Bags',
      subItems: [
        'OPC 53 Grade',
        'OPC 43 Grade',
        'PPC (Portland Pozzolana Cement)',
        'White Cement',
        'Waterproof Cement',
        'Rapid Hardening Cement',
        'Slag Cement',
      ],
    ),
    MaterialCategoryMeta(
      name: 'Steel',
      slug: 'steel',
      label: 'Steel Type / Diameter',
      defaultUnit: 'Ton',
      subItems: [
        'TMT 8mm',
        'TMT 10mm',
        'TMT 12mm',
        'TMT 16mm',
        'TMT 20mm',
        'TMT 25mm',
        'Binding Wire',
        'MS Flat / Angle',
        'Structural Steel (Beams / Channels)',
      ],
    ),
    MaterialCategoryMeta(
      name: 'Sand',
      slug: 'sand',
      label: 'Sand Type',
      defaultUnit: 'Units',
      subItems: [
        'M-Sand (Manufactured Sand for Concreting)',
        'P-Sand (Plastering Sand)',
        'River Sand',
        'Pit Sand / Filling Sand',
      ],
    ),
    MaterialCategoryMeta(
      name: 'Aggregate',
      slug: 'aggregate',
      label: 'Aggregate Type / Size',
      defaultUnit: 'Units',
      subItems: [
        '10mm Aggregate (Chips)',
        '20mm Aggregate (Roofing & Columns)',
        '40mm Aggregate (Foundations)',
        'GSB (Granular Sub Base)',
        'Quarry Dust',
        'Stone Boulder',
      ],
    ),
    MaterialCategoryMeta(
      name: 'Tiles',
      slug: 'tiles',
      label: 'Tiles Type & Size',
      defaultUnit: 'Sq.Ft',
      subItems: [
        'Vitrified Floor Tiles (2x2 ft)',
        'Vitrified Floor Tiles (4x2 ft)',
        'Ceramic Wall Tiles',
        'Anti-Skid Bathroom Tiles',
        'Parking / Exterior Paver Tiles',
        'Kitchen Dado Tiles',
        'Step & Riser Tiles',
      ],
    ),
    MaterialCategoryMeta(
      name: 'Granite / Marble',
      slug: 'granite',
      label: 'Granite / Stone Variety',
      defaultUnit: 'Sq.Ft',
      subItems: [
        'Black Galaxy Granite',
        'Tan Brown Granite',
        'Jet Black Granite',
        'Kashmir White Granite',
        'Steel Grey Granite',
        'Ruby Red Granite',
        'Indian Marble Slabs',
      ],
    ),
    MaterialCategoryMeta(
      name: 'RMC / Ready Mix Concrete',
      slug: 'rmc',
      label: 'Concrete Grade',
      defaultUnit: 'Cum',
      subItems: [
        'M15 Concrete',
        'M20 Concrete',
        'M25 Concrete',
        'M30 Concrete',
        'M35 Concrete',
        'M40 Concrete',
      ],
    ),
    MaterialCategoryMeta(
      name: 'Plumbing & Sanitary',
      slug: 'plumber',
      label: 'Plumbing Item',
      defaultUnit: 'Nos',
      subItems: [
        'CPVC Pipes & Fittings',
        'UPVC Pipes & Fittings',
        'PVC Drainage Pipes',
        'Water Storage Tank (Sintex / Overhead)',
        'Sanitaryware / WC / Wash Basins',
        'Taps, Valves & Faucets',
      ],
    ),
    MaterialCategoryMeta(
      name: 'Electrical & Wire',
      slug: 'electricalwire',
      label: 'Electrical Item',
      defaultUnit: 'Coil',
      subItems: [
        '1.0 sq mm Wire',
        '1.5 sq mm Wire',
        '2.5 sq mm Wire',
        '4.0 sq mm Wire',
        'PVC Conduit Pipes',
        'Modular Switches & Sockets',
        'MCB & Distribution Board',
        'LED Lights & Fixtures',
      ],
    ),
    MaterialCategoryMeta(
      name: 'Painting',
      slug: 'painting',
      label: 'Paint Item',
      defaultUnit: 'Litre',
      subItems: [
        'Wall Putty',
        'Interior Primer',
        'Exterior Primer',
        'Interior Emulsion',
        'Exterior Apex Emulsion',
        'Enamel Paint (Wood & Metal)',
        'Waterproofing Chemical',
      ],
    ),
    MaterialCategoryMeta(
      name: 'Wood & Timber',
      slug: 'wood',
      label: 'Wood / Timber Variety',
      defaultUnit: 'Cft',
      subItems: [
        'Teak Wood',
        'Sal Wood',
        'Plywood (Commercial MR)',
        'Plywood (Marine / BWP)',
        'Flush Doors',
        'MDF / Particle Board',
      ],
    ),
    MaterialCategoryMeta(
      name: 'Others / Hardware',
      slug: 'others',
      label: 'Item Type',
      defaultUnit: 'Nos',
      subItems: [
        'Hardware & Fasteners (Nails, Screws, Bolts)',
        'Door Locks & Hinges',
        'Safety Helmets & Nets',
        'Scaffolding Pipes & Clamps',
        'Waterproofing Tape & Adhesives',
        'Miscellaneous Site Material',
      ],
    ),
  ];

  static MaterialCategoryMeta? getCategoryBySlug(String slug) {
    try {
      return categories.firstWhere(
        (c) => c.slug.toLowerCase() == slug.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  static MaterialCategoryMeta? getCategoryByName(String name) {
    try {
      return categories.firstWhere(
        (c) => c.name.toLowerCase() == name.toLowerCase() ||
               c.slug.toLowerCase() == name.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }
}

class AllMaterialOrderItem {
  final String id;
  final String categorySlug;
  final String categoryName;
  final String name;

  final TextEditingController quantityController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  late final RxString unit;
  late final RxDouble gstRate;

  // Observable trigger for reactive recalculations
  final RxInt changeNotifier = 0.obs;

  AllMaterialOrderItem({
    required this.id,
    required this.categorySlug,
    required this.categoryName,
    required this.name,
    String? defaultUnit,
    double defaultGst = 18.0,
    double? initialQuantity,
    double? initialPrice,
  }) {
    unit = (defaultUnit ?? 'Nos').obs;
    gstRate = defaultGst.obs;

    if (initialQuantity != null && initialQuantity > 0) {
      quantityController.text = initialQuantity.toString().replaceAll(RegExp(r'\.0$'), '');
    }
    if (initialPrice != null && initialPrice > 0) {
      priceController.text = initialPrice.toString().replaceAll(RegExp(r'\.0$'), '');
    }

    quantityController.addListener(() => changeNotifier.value++);
    priceController.addListener(() => changeNotifier.value++);
  }

  double get quantity => double.tryParse(quantityController.text.trim()) ?? 0.0;
  double get price => double.tryParse(priceController.text.trim()) ?? 0.0;

  double get baseTotal => quantity * price;
  double get gstAmount => baseTotal * (gstRate.value / 100.0);
  double get totalInclGst => baseTotal + gstAmount;

  void dispose() {
    quantityController.dispose();
    priceController.dispose();
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': categoryName,
      'category_slug': categorySlug,
      'quantity': quantity,
      'unit': unit.value,
      'price': price,
      'gst': gstRate.value,
      'total': totalInclGst,
    };
  }
}
