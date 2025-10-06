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

ServerEvents.recipes((event) => {
  modifySmeltingRecipes(event);
  modifyBlastingRecipes(event);
});
