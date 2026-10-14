// Generated Material Form Configuration matching Web Portal materialCategoryConfig
class MaterialFormConfig {
  final String label;
  final List<String> options;
  final String specLabel;
  final List<String> specOptions;
  final List<String> units;
  final bool attachment;

  const MaterialFormConfig({
    required this.label,
    required this.options,
    required this.specLabel,
    required this.specOptions,
    required this.units,
    this.attachment = false,
  });
}

class MaterialFormRegistry {
  static const Map<String, MaterialFormConfig> configs = {
    'bricks': MaterialFormConfig(
      label: "Brick / Block Type",
      options: ["Red Clay Brick", "Fly Ash Bricks", "AAC Blocks", "Solid Concrete Blocks", "Hollow Concrete Blocks", "Wire Cut Bricks", "Clay Paver Bricks", "Stone"],
      specLabel: "Size / Specification",
      specOptions: ["9\" x 4\" x 3\"", "4\" AAC Block (600x200x100mm)", "6\" AAC Block (600x200x150mm)", "8\" AAC Block (600x200x200mm)", "4\" Solid Block", "6\" Solid Block", "9\" Solid Block", "Chamber Bricks", "Country Bricks"],
      units: ["Nos", "Pieces", "Load", "Thousand"],
      attachment: false,
    ),
    'sand': MaterialFormConfig(
      label: "Sand Type",
      options: ["River Sand", "M-Sand (Manufactured Sand - Concreting)", "P-Sand (Plastering Sand)", "Filling Sand / Pit Sand"],
      specLabel: "Zone / Source",
      specOptions: ["Zone II Concreting Sand", "Double Washed M-Sand", "Fine Plastering P-Sand", "Pit Sand / Earth Filling"],
      units: ["CFT", "Ton", "Brass", "Units", "Load"],
      attachment: false,
    ),
    'cement': MaterialFormConfig(
      label: "Cement Grade / Type",
      options: ["OPC 53 Grade", "OPC 43 Grade", "PPC (Portland Pozzolana)", "PSC (Portland Slag Cement)", "White Cement", "Waterproof Cement"],
      specLabel: "Brand / Manufacturer",
      specOptions: ["UltraTech", "ACC", "Ambuja", "Dalmia", "Ramco", "Chettinad", "Birla A1", "Priya Cement", "Maha Cement", "Zuari", "Coromandel", "JK Cement"],
      units: ["Bags", "Ton", "Kg"],
      attachment: false,
    ),
    'aggregate': MaterialFormConfig(
      label: "Aggregate Size",
      options: ["6mm Aggregate", "10mm Aggregate", "12mm Aggregate", "20mm Aggregate", "40mm Aggregate", "GSB (Granular Sub Base)", "WMM (Wet Mix Macadam)", "Quarry Dust / Stone Dust"],
      specLabel: "Stone Type / Spec",
      specOptions: ["Blue Metal Crushed Stone", "Hard Granite Aggregate", "Washed Aggregate", "Quarry Dust"],
      units: ["CFT", "Ton", "Brass", "Units", "Load"],
      attachment: false,
    ),
    'jally': MaterialFormConfig(
      label: "Jally Size",
      options: ["6mm Jally", "12mm Jally", "20mm Jally", "40mm Jally", "Stone Dust"],
      specLabel: "Type",
      specOptions: ["Blue Metal Jally", "Hand Broken Jally", "Crusher Run"],
      units: ["CFT", "Ton", "Brass", "Units", "Load"],
      attachment: false,
    ),
    'gravel': MaterialFormConfig(
      label: "Material Type",
      options: ["Gravel", "Red Earth / Soil", "Moorum", "Quarry Dust", "Filling Soil"],
      specLabel: "Application",
      specOptions: ["Foundation Filling", "Plinth Filling", "Road Base Compaction", "Landscaping"],
      units: ["CFT", "Ton", "Brass", "Load", "Trips"],
      attachment: false,
    ),
    'steel': MaterialFormConfig(
      label: "Item Type",
      options: ["TMT Steel Bars", "Binding Wire", "Mild Steel (MS) Rods", "GI Wire", "Steel Angles", "Steel Channels", "Steel Plates", "MS Pipes", "GI Pipes", "Stainless Steel (SS)"],
      specLabel: "Diameter / Grade",
      specOptions: ["8mm TMT Bar", "10mm TMT Bar", "12mm TMT Bar", "16mm TMT Bar", "20mm TMT Bar", "25mm TMT Bar", "32mm TMT Bar", "Fe 500D", "Fe 550D", "18 Gauge Binding Wire", "20 Gauge Binding Wire"],
      units: ["Ton", "Tons", "Kg", "Bundles", "Nos"],
      attachment: false,
    ),
    'rmc': MaterialFormConfig(
      label: "Concrete Grade",
      options: ["M10", "M15", "M20", "M25", "M30", "M35", "M40", "M45", "M50", "Ready-Mix Concrete (RMC)", "Precast Concrete"],
      specLabel: "Pour Structure / Slump",
      specOptions: ["Footing / Raft Foundation", "Columns", "Plinth Beams", "Roof Slab & Beams", "Retaining Wall", "Slump 100-120mm", "Slump 120-150mm"],
      units: ["M Cube", "Load"],
      attachment: false,
    ),
    'rcconcrete': MaterialFormConfig(
      label: "Concrete Grade",
      options: ["M15", "M20", "M25", "M30", "M35"],
      specLabel: "Structure Element",
      specOptions: ["Columns", "Beams", "Roof Slab", "Lintel & Sunshade", "Foundation"],
      units: ["M Cube", "CFT"],
      attachment: false,
    ),
    'woodcarpentry': MaterialFormConfig(
      label: "Item Type",
      options: ["Plywood (Commercial MR)", "Waterproof Plywood (BWP/BWR)", "Marine Plywood", "MDF Board", "HDF Board", "Particle Board", "Teak Wood", "Sal Wood", "Neem Wood", "Pine Wood", "Wooden Frames", "Wooden Doors", "Laminates (Mica)", "Veneers"],
      specLabel: "Thickness / Size",
      specOptions: ["6mm (8x4 ft)", "8mm (8x4 ft)", "12mm (8x4 ft)", "16mm (8x4 ft)", "18mm (8x4 ft)", "1mm Laminate", "0.8mm Laminate", "5x3 inch Frame", "4x2.5 inch Frame"],
      units: ["Sqft", "CFT", "Sheets", "Rft", "Nos"],
      attachment: true,
    ),
    'doorswindows': MaterialFormConfig(
      label: "Item Type",
      options: ["Main Entrance Wooden Door", "Bedroom Flush Door", "UPVC Sliding Windows", "UPVC Casement Windows", "Aluminium Sliding Windows", "Aluminium Doors", "Glass Partition", "Toughened Glass", "Laminated Glass", "Door Frames", "Window Frames", "Mosquito Mesh Doors", "Bathroom PVC Doors"],
      specLabel: "Dimension / Glass Spec",
      specOptions: ["7' x 3'6\" (Main Door)", "7' x 3' (Bedroom)", "7' x 2'6\" (Toilet)", "4' x 4' (Window)", "5' x 4' (Window)", "6' x 4' (Window)", "5mm Clear Glass", "8mm Toughened Glass", "12mm Toughened Glass"],
      units: ["Nos", "Sets", "Sqft"],
      attachment: true,
    ),
    'tiles': MaterialFormConfig(
      label: "Tile Type",
      options: ["Vitrified Floor Tiles", "Ceramic Wall Tiles", "Anti-skid Bathroom Tiles", "Parking Paver Tiles", "Kitchen Glazed Tiles", "Subway / Decorative Tiles", "Step & Riser Tiles", "Interlocking Paver Blocks"],
      specLabel: "Size / Finish",
      specOptions: ["2x2 ft (600x600mm)", "4x2 ft (1200x600mm)", "2x1 ft (600x300mm)", "1x1 ft (300x300mm)", "800x1600mm", "Glossy Finish", "Matt Finish", "Satin Finish", "Rustic Finish", "High-Gloss"],
      units: ["Boxes", "Sqft", "Pieces"],
      attachment: true,
    ),
    'granite': MaterialFormConfig(
      label: "Stone Type",
      options: ["Granite", "Black Galaxy Granite", "Jet Black Granite", "Steel Grey Granite", "Tan Brown Granite", "Indian White Marble", "Italian Marble", "Kota Stone", "Kadappa Stone", "Sandstone"],
      specLabel: "Thickness / Application",
      specOptions: ["18mm Polished Slab", "20mm Polished Slab", "Kitchen Platform Slab", "Staircase Treads & Risers", "Door / Window Frame Jambs", "Leather / Flamed Finish"],
      units: ["Sqft", "Slabs", "Rft"],
      attachment: true,
    ),
    'painting': MaterialFormConfig(
      label: "Paint / Finish Type",
      options: ["Wall Putty", "Interior Primer", "Exterior Primer", "Interior Acrylic Emulsion", "Exterior Weatherproof Emulsion", "Enamel Paint (Oil Based)", "PU / Wood Polish", "Waterproof Paint", "Texture Paint", "Thinner", "Paint Brushes", "Rollers"],
      specLabel: "Brand / Shade",
      specOptions: ["Asian Paints Royale", "Asian Paints Apcolite", "Asian Paints Apex Ultima", "Asian Paints Tractor Emulsion", "Berger WeatherCoat", "Nerolac Beauty", "Dulux Velvet", "Birla White Putty", "JK WallMaxx Putty"],
      units: ["Litres", "Ltr", "Kg", "Pack", "Buckets", "Tins"],
      attachment: true,
    ),
    'plumber': MaterialFormConfig(
      label: "Item Category",
      options: ["CPVC Pipes", "CPVC Fittings (Elbow/Tee/Coupler)", "UPVC Pipes", "UPVC Fittings", "PVC SWR Drainage Pipes", "HDPE Pipes", "GI Pipes", "Ball Valves / Concealed Valves", "Overhead Water Tanks", "Wash Basins", "Toilets (EWC/IWC)", "Faucets / Taps", "CP Bath Fittings"],
      specLabel: "Diameter / Size",
      specOptions: ["1/2\" (15mm)", "3/4\" (20mm)", "1\" (25mm)", "1.25\" (32mm)", "1.5\" (40mm)", "2\" (50mm)", "2.5\" (65mm)", "3\" (75mm)", "4\" (110mm)", "6\" (160mm)", "500 Litre Tank", "1000 Litre Tank", "2000 Litre Tank"],
      units: ["Nos", "Meter", "Bundles", "Pieces", "Sets"],
      attachment: true,
    ),
    'electricalwire': MaterialFormConfig(
      label: "Item Category",
      options: ["House Wires (FR/FRLS)", "Armoured Power Cables", "PVC Conduits & Accessories", "Modular Switches & Sockets", "Distribution Boards (DB)", "Miniature Circuit Breakers (MCB)", "RCCB / ELCB", "LED Ceiling Lights", "Tube Lights", "Ceiling Fans", "Exhaust Fans", "Cable Trays", "Junction Boxes"],
      specLabel: "Spec / Gauge / Rating",
      specOptions: ["0.75 sq mm Wire", "1.0 sq mm Wire", "1.5 sq mm Wire", "2.5 sq mm Wire", "4.0 sq mm Wire", "6.0 sq mm Wire", "10 sq mm Wire", "16 sq mm Wire", "6A Modular Switch", "16A Power Socket", "32A DP MCB", "63A 4-Pole MCB"],
      units: ["Meter", "Nos", "Roll", "Coil", "Pack", "Boxes", "Sets"],
      attachment: true,
    ),
    'hardware': MaterialFormConfig(
      label: "Item Type",
      options: ["Drywall Screws", "Wood Screws", "Self-Tapping Screws", "Wire Nails", "Concrete Nails", "Nuts & Bolts", "Washers", "Anchor Fasteners / Rawlplugs", "Tower Bolts", "Mortise Locks & Handles", "Padlocks", "Hinges (Butt/Concealed)", "Drawer Slides / Telescopic Channels", "Brackets & Clamps", "Metal Fittings"],
      specLabel: "Size / Spec",
      specOptions: ["1 inch", "1.5 inch", "2 inch", "2.5 inch", "3 inch", "4 inch", "5 inch", "6 inch", "8 inch", "10 inch", "12 inch", "SS 304 Grade", "MS Zinc Plated"],
      units: ["Pack", "Boxes", "Nos", "Kg", "Pairs", "Pieces"],
      attachment: false,
    ),
    'waterproofinginsulation': MaterialFormConfig(
      label: "Item Type",
      options: ["Integral Liquid Waterproofing (LW+)", "2K Acrylic Polymer Coating", "Bitumen Sheet / Membrane", "APP Membrane", "Bituminous Primer / Coating", "PVC Waterproofing Sheet", "Tile Adhesive", "Epoxy Tile Grout", "Silicone Sealant", "PU Sealant", "Concrete Curing Compound", "Thermal Insulation", "Acoustic Insulation"],
      specLabel: "Brand / Spec",
      specOptions: ["Dr. Fixit 101 LW+", "Dr. Fixit Fastflex", "Dr. Fixit Pidifin 2K", "Fosroc Nitoproof", "SikaTop Seal 107", "Roff Tile Adhesive", "Asian Paints SmartCare Damp Block"],
      units: ["Litres", "Kg", "Pack", "Bags", "Roll", "Buckets"],
      attachment: true,
    ),
    'roofing': MaterialFormConfig(
      label: "Roofing Type",
      options: ["Colour-Coated Galvalume Sheets", "GI Corrugated Sheets", "Polycarbonate Multiwall Sheets", "Polycarbonate Corrugated Sheets", "Mangalore Clay Roof Tiles", "UPVC Roofing Sheets", "Bitumen Roofing Sheets", "Fibre Cement Sheets", "Ridge Caps", "Gutter & Downpipes"],
      specLabel: "Thickness / Length",
      specOptions: ["0.35mm", "0.40mm", "0.45mm", "0.50mm", "8 Feet Length", "10 Feet Length", "12 Feet Length", "14 Feet Length", "16 Feet Length", "18 Feet Length", "20 Feet Length"],
      units: ["Rft", "Meter", "Sheets", "Sqft", "Nos"],
      attachment: true,
    ),
    'finishingmaterials': MaterialFormConfig(
      label: "Item Type",
      options: ["Wall Putty", "Gypsum Plaster (One Coat)", "Gypsum Ceiling Boards", "Cement Fibre Boards", "GI False Ceiling Perimeter Channel", "GI Ceiling Section", "POP (Plaster of Paris)", "PVC Wall & Ceiling Panels", "Acoustic Ceiling Tiles", "Corner Beads & Joint Tape", "Tile Adhesive", "Grout"],
      specLabel: "Brand / Thickness",
      specOptions: ["Saint-Gobain Gyproc", "USG Boral", "Armstrong", "Birla White", "12.5mm Gypsum Board", "9.5mm Gypsum Board", "8x4 ft Sheet", "6x4 ft Sheet"],
      units: ["Bags", "Sheets", "Bundles", "Sqft", "Nos"],
      attachment: true,
    ),
    'externaloutdoor': MaterialFormConfig(
      label: "Item Type",
      options: ["Interlocking Paver Blocks", "Kerb Stones", "Precast Compound Wall Slabs & Posts", "Chain Link Fencing", "Barbed Wire", "RCC Hume Drainage Pipes", "Manhole Covers & Frames", "Landscaping Stones", "Cement Poles", "Grass Pavers"],
      specLabel: "Grade / Dimension",
      specOptions: ["60mm Paver (M30)", "80mm Heavy Paver (M40)", "100mm Kerb Stone", "150mm Kerb Stone", "300mm Hume Pipe (NP2)", "450mm Hume Pipe (NP2)", "600mm Hume Pipe (NP3)", "Heavy Duty SFRC Manhole Cover"],
      units: ["Sqft", "Nos", "Rft", "Meter", "Pairs"],
      attachment: false,
    ),
    'scaffoldingformwork': MaterialFormConfig(
      label: "Equipment / Material Type",
      options: ["MS Adjustable Props", "Cuplock Verticals", "Cuplock Ledgers", "Film-Faced Shuttering Plywood", "MS Shuttering Plates", "Tie Rods & Wing Nuts", "Scaffolding Swivel / Fixed Couplers", "Adjustable Base Jacks", "U-Head Jacks", "Scaffolding Pipes (40mm)", "Steel Scaffolding Spans"],
      specLabel: "Size / Specification",
      specOptions: ["2m x 3m Adjustable Props", "2m x 3.5m Adjustable Props", "12mm Film-Faced Plywood (8x4 ft)", "900 x 600mm MS Shuttering Plates", "1200 x 600mm MS Shuttering Plates", "2.5m Cuplock Vertical", "1.5m Cuplock Ledger", "Tie Rod with Water Barrier"],
      units: ["Nos", "Sheets", "Sets", "Sqft", "Ton"],
      attachment: true,
    ),
    'safetyppe': MaterialFormConfig(
      label: "Safety Item",
      options: ["Safety Helmets (ISI Mark)", "Safety Shoes (Steel Toe)", "High-Visibility Reflective Jackets", "Full Body Safety Harness", "Safety Fall Protection Nets", "Heavy Duty Cotton / Leather Gloves", "Rubber Electrical Gloves", "Safety Protective Goggles", "Caution / Barricade Tape", "Fire Extinguishers"],
      specLabel: "Specification / Rating",
      specOptions: ["ISI Marked HDPE Shell", "Class A / Class B", "Steel Toe Cap (Size 7-11)", "Double Lanyard Safety Harness", "50mm Retroreflective Tape", "4kg ABC Powder Fire Extinguisher"],
      units: ["Nos", "Pairs", "Roll", "Sets"],
      attachment: false,
    ),
    'sanitarybathfittings': MaterialFormConfig(
      label: "Sanitary Item",
      options: ["European Water Closet (EWC)", "Indian Water Closet (IWC / Orissa Pan)", "Wall Hung Toilet with Concealed Cistern", "Countertop Wash Basin", "Pedestal Wash Basin", "Urinals & Sensors", "Health Faucets", "Basin Mixers", "Wall Mixers / Diverters", "Overhead Showers", "Bath Spouts", "Bottle Traps", "CP Towel Rods & Accessories"],
      specLabel: "Brand / Model",
      specOptions: ["Jaquar", "Parryware", "Hindware", "Cera", "Kohler", "Grohe", "White Ceramic", "Chrome Finish"],
      units: ["Nos", "Sets", "Pieces"],
      attachment: true,
    ),
    'glassaluminium': MaterialFormConfig(
      label: "Item Type",
      options: ["Toughened Glass", "Laminated Safety Glass", "Clear Float Glass", "Frosted / Tinted Glass", "Aluminium Partition Sections", "Aluminium Window Sections", "Structural Glazing Aluminium Profiles", "Spider Glazing Fittings", "Floor Springs & Patch Fittings", "Silicone Weather Sealants"],
      specLabel: "Thickness / Profile Spec",
      specOptions: ["5mm Clear Glass", "6mm Toughened Glass", "8mm Toughened Glass", "10mm Toughened Glass", "12mm Toughened Glass", "63.5 x 38.1mm Alu Section (1.5mm)", "100 x 44.5mm Alu Section (2.0mm)", "Black Powder Coated", "Anodized Silver"],
      units: ["Sqft", "Sheets", "Nos", "Rft"],
      attachment: true,
    ),
    'welding': MaterialFormConfig(
      label: "Item Type",
      options: ["Welding Electrodes / Rods", "MS Rods", "MS Angles", "MS Channels", "MS Flats", "MS Square Tubes", "MS Round Pipes", "Cutting Wheels", "Grinding Wheels", "Industrial Gas Cylinders (Oxygen/Acetylene)"],
      specLabel: "Size / Gauge",
      specOptions: ["8 SWG Electrode (6013)", "10 SWG Electrode (6013)", "12 SWG Electrode (7018)", "25x25x3 mm Angle", "40x40x5 mm Angle", "50x50x6 mm Angle", "75x40 mm Channel", "100x50 mm Channel", "14 inch Cutting Wheel", "4 inch Grinding Wheel"],
      units: ["Kg", "Pack", "Nos", "Ton", "Pieces"],
      attachment: false,
    ),
    'lift': MaterialFormConfig(
      label: "Lift Type",
      options: ["Passenger Lift (6 Passengers)", "Passenger Lift (8 Passengers)", "Goods Lift / Material Hoist", "Hydraulic Home Lift", "Capsule Glass Lift", "Dumbwaiter Lift", "Lift Spare Parts & Maintenance"],
      specLabel: "Stops / Capacity",
      specOptions: ["G+1 (2 Stops)", "G+2 (3 Stops)", "G+3 (4 Stops)", "G+4 (5 Stops)", "G+5 (6 Stops)", "408 Kg Capacity", "544 Kg Capacity", "1000 Kg Goods Capacity"],
      units: ["Nos", "Sets"],
      attachment: true,
    ),
    'transport': MaterialFormConfig(
      label: "Vehicle / Machine Type",
      options: ["Tipper / Lorry (6 Wheeler)", "Tipper / Lorry (10 Wheeler)", "JCB Excavator (3DX)", "Hitachi / Poclain Heavy Excavator", "Bobcat Compact Loader", "Concrete Boom Pump", "Tractor with Trolley", "Hydra Mobile Crane (12T/14T)", "Vibratory Road Roller", "Trailer / Flatbed"],
      specLabel: "Billing Basis / Shift",
      specOptions: ["Per Hour (with Diesel & Driver)", "Per Day (8 Hours)", "Per Trip / Load", "Per Month Contract", "Demolition & Debris Disposal"],
      units: ["Load", "Unit", "Hours", "Days", "Trips"],
      attachment: false,
    ),
    'interior': MaterialFormConfig(
      label: "Work Type",
      options: ["Modular Kitchen Cabinets", "Bedroom Wardrobes", "TV Unit & Wall Panelling", "False Ceiling Design", "Glass Partitions", "Loose Furniture & Bed Units", "Shoe Racks & Storage", "Wall Paper & Texture Finish"],
      specLabel: "Finish / Material Spec",
      specOptions: ["High-Gloss Acrylic Finish", "Anti-Fingerprint Laminate", "PU Polish Finish", "Natural Wood Veneer", "Soft-Close Hardware (Hettich/Blum)", "Toughened Fluted Glass"],
      units: ["Sqft", "Rft", "Sets", "Ls"],
      attachment: true,
    ),
    'watercan': MaterialFormConfig(
      label: "Can Size",
      options: ["20 Litre Can", "25 Litre Can"],
      specLabel: "Type",
      specOptions: ["Commercial RO Purified Water", "Packaged Drinking Water"],
      units: ["Nos", "Pack", "Units"],
      attachment: false,
    ),
    'lorrywater': MaterialFormConfig(
      label: "Tanker Size",
      options: ["6,000 Litre Tanker", "8,000 Litre Tanker", "12,000 Litre Tanker", "18,000 Litre Tanker"],
      specLabel: "Water Purpose",
      specOptions: ["Construction Curing & Concrete Mixing Water", "Ground Raw Water", "Drinking / Kitchen Supply"],
      units: ["Load", "Litres", "Unit"],
      attachment: false,
    ),
    'tea': MaterialFormConfig(
      label: "Refreshment Type",
      options: ["Morning Tea / Coffee", "Afternoon Tea / Coffee", "Snacks & Biscuits", "Drinking Water Supply"],
      specLabel: "Supply Schedule",
      specOptions: ["Daily Site Supply", "Weekly Supply", "Overtime Snacks"],
      units: ["Cups", "Nos", "Pack", "Days"],
      attachment: false,
    ),
  };

  static MaterialFormConfig getConfig(String rawKey) {
    if (rawKey.isEmpty) {
      return const MaterialFormConfig(
        label: 'Item Type',
        options: [],
        specLabel: 'Size / Specification',
        specOptions: [],
        units: ['Nos', 'Units', 'Bags', 'Ton', 'Kg', 'Sq.Ft', 'Cft', 'Cum'],
      );
    }

    final clean = rawKey.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    
    if (configs.containsKey(clean)) {
      return configs[clean]!;
    }

    if (clean.contains('brick') || clean.contains('block')) return configs['bricks']!;
    if (clean.contains('sand')) return configs['sand']!;
    if (clean.contains('cement')) return configs['cement']!;
    if (clean.contains('steel') || clean.contains('tmt')) return configs['steel']!;
    if (clean.contains('electric') || clean.contains('wire') || clean.contains('cable')) return configs['electricalwire']!;
    if (clean.contains('tile')) return configs['tiles']!;
    if (clean.contains('paint')) return configs['painting']!;
    if (clean.contains('plumb')) return configs['plumber']!;
    if (clean.contains('granite') || clean.contains('marble')) return configs['granite']!;
    if (clean.contains('jally')) return configs['jally']!;
    if (clean.contains('aggregate')) return configs['aggregate']!;
    if (clean.contains('gravel')) return configs['gravel']!;
    if (clean.contains('door') || clean.contains('window')) return configs['doorswindows']!;
    if (clean.contains('wood') || clean.contains('timber') || clean.contains('carpentr')) return configs['woodcarpentry']!;
    if (clean.contains('sanitary') || clean.contains('bath')) return configs['sanitarybathfittings']!;
    if (clean.contains('safety') || clean.contains('ppe')) return configs['safetyppe']!;
    if (clean.contains('hardware')) return configs['hardware']!;
    if (clean.contains('waterproof') || clean.contains('insulat')) return configs['waterproofinginsulation']!;
    if (clean.contains('roof')) return configs['roofing']!;
    if (clean.contains('glass') || clean.contains('alumin')) return configs['glassaluminium']!;
    if (clean.contains('weld')) return configs['welding']!;
    if (clean.contains('rmc')) return configs['rmc']!;
    if (clean.contains('rcconcrete') || clean.contains('concrete')) return configs['rcconcrete']!;
    if (clean.contains('lift')) return configs['lift']!;
    if (clean.contains('transport') || clean.contains('vehicle')) return configs['transport']!;
    if (clean.contains('interior')) return configs['interior']!;
    if (clean.contains('watercan')) return configs['watercan']!;
    if (clean.contains('lorry')) return configs['lorrywater']!;
    if (clean.contains('tea')) return configs['tea']!;
    if (clean.contains('scaffold') || clean.contains('formwork')) return configs['scaffoldingformwork']!;
    if (clean.contains('finish')) return configs['finishingmaterials']!;
    if (clean.contains('outdoor') || clean.contains('external')) return configs['externaloutdoor']!;

    for (var entry in configs.entries) {
      if (clean.contains(entry.key) || entry.key.contains(clean)) {
        return entry.value;
      }
    }

    return const MaterialFormConfig(
      label: 'Item Type',
      options: [],
      specLabel: 'Size / Specification',
      specOptions: [],
      units: ['Nos', 'Units', 'Bags', 'Ton', 'Kg', 'Sq.Ft', 'Cft', 'Cum'],
    );
  }
}
