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

ServerEvents.recipes((event) => {
  modifySmeltingRecipes(event);
  modifyBlastingRecipes(event);
  modifyAndesiteAlloyRecipes(event);
});
