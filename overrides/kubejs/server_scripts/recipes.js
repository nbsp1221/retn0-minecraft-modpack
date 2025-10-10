// priority: 0

const bloomeryOres = ['iron', 'gold', 'silver', 'copper', 'zinc', 'tin', 'lead', 'nickel'];
const advancedOres = ['osmium', 'aluminum', 'uranium'];

function modifySmeltingRecipes(event) {
  // Replace smelting recipe outputs from ingots to nuggets
  bloomeryOres.forEach((ore) => {
    event.replaceOutput({ type: 'minecraft:smelting' }, `#forge:ingots/${ore}`, `#forge:nuggets/${ore}`);
  });

  // Remove smelting recipes outputs ingots
  advancedOres.forEach((ore) => {
    event.remove({ type: 'minecraft:smelting', output: `#forge:ingots/${ore}` });
  });
}

function modifyBlastingRecipes(event) {
  // Replace blasting recipe outputs from ingots to nuggets
  bloomeryOres.forEach((ore) => {
    event.replaceOutput({ type: 'minecraft:blasting' }, `#forge:ingots/${ore}`, `#forge:nuggets/${ore}`);
  });

  // Remove blasting recipes outputs ingots
  advancedOres.forEach((ore) => {
    event.remove({ type: 'minecraft:blasting', output: `#forge:ingots/${ore}` });
  });
}

function modifyAndesiteAlloyRecipes(event) {
  // Remove existing recipes
  event.remove({ id: 'create:crafting/materials/andesite_alloy' });
  event.remove({ id: 'create:crafting/materials/andesite_alloy_from_zinc' });
  event.remove({ id: 'create:mixing/andesite_alloy' });
  event.remove({ id: 'create:mixing/andesite_alloy_from_zinc' });
  event.remove({ id: 'tconstruct:compat/create/andesite_alloy_iron' });
  event.remove({ id: 'tconstruct:compat/create/andesite_alloy_zinc' });
  event.remove({ id: 'thermal:compat/create/smelter_create_alloy_andesite_alloy' });

  // Add new recipes using algal bricks
  event.shaped(Item.of('create:andesite_alloy', 2), [
    'AA',
    'BB',
  ], {
    A: '#forge:andesite',
    B: 'architects_palette:algal_brick',
  });

  event.shaped(Item.of('create:andesite_alloy', 2), [
    'BB',
    'AA',
  ], {
    A: '#forge:andesite',
    B: 'architects_palette:algal_brick',
  });

  event.recipes.create.mixing(
    Item.of('create:andesite_alloy', 2),
    ['#forge:andesite', 'architects_palette:algal_brick'],
  );
}

function modifyGroutRecipes(event) {
  event.remove({ id: 'tconstruct:smeltery/seared/grout' });
  event.remove({ id: 'tconstruct:smeltery/seared/grout_multiple' });

  event.recipes.create.mixing(
    '2x tconstruct:grout',
    ['#forge:clay', 'minecraft:flint', 'farmersdelight:straw', Fluid.of('water', 250)],
  );

  event.recipes.create.mixing(
    '8x tconstruct:grout',
    ['#forge:storage_blocks/clay', '4x minecraft:flint', '4x farmersdelight:straw', Fluid.of('water', 1000)],
  );
}

function modifyRubberRecipes(event) {
  // Remove existing rubber recipes
  event.remove({ id: 'thermal:rubber_from_vine' });
  event.remove({ id: 'thermal:rubber_from_dandelion' });
  event.remove({ id: 'thermal:rubber_3' });

  // Remove existing cured rubber recipes
  event.remove({ type: 'minecraft:smelting', output: 'thermal:cured_rubber' });
  event.remove({ id: 'thermal:machines/smelter/smelter_cured_rubber' });

  // Coagulation process (using low-efficiency resin)
  event.recipes.create.mixing(
    'thermal:rubber',
    [
      Fluid.of('thermal:resin', 1000),
      '#forge:slimeballs',
    ],
  ).heated();

  // Coagulation process (using high-efficiency latex)
  event.recipes.create.mixing(
    '4x thermal:rubber',
    [
      Fluid.of('thermal:latex', 1000),
      '#forge:slimeballs',
    ],
  );

  // Vulcanization process
  event.recipes.create.mixing(
    'thermal:cured_rubber',
    [
      'thermal:rubber',
      '#forge:dusts/sulfur',
    ],
  ).heated();
}

function modifyBeltRecipes(event) {
  event.remove({ output: 'create:belt_connector' });

  event.shaped('2x create:belt_connector', [
    'AAA',
    'AAA',
  ], {
    A: 'thermal:cured_rubber',
  });

  event.recipes.create.deploying(
    'create:belt_connector',
    ['thermal:cured_rubber', '#forge:fabric_hemp'],
  );
}

ServerEvents.recipes((event) => {
  modifySmeltingRecipes(event);
  modifyBlastingRecipes(event);
  modifyAndesiteAlloyRecipes(event);
  modifyGroutRecipes(event);
  modifyRubberRecipes(event);
  modifyBeltRecipes(event);
});
