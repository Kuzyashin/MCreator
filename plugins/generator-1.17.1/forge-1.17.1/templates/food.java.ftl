<#--
 # MCreator (https://mcreator.net/)
 # Copyright (C) 2012-2020, Pylo
 # Copyright (C) 2020-2021, Pylo, opensource contributors
 # 
 # This program is free software: you can redistribute it and/or modify
 # it under the terms of the GNU General Public License as published by
 # the Free Software Foundation, either version 3 of the License, or
 # (at your option) any later version.
 # 
 # This program is distributed in the hope that it will be useful,
 # but WITHOUT ANY WARRANTY; without even the implied warranty of
 # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 # GNU General Public License for more details.
 # 
 # You should have received a copy of the GNU General Public License
 # along with this program.  If not, see <https://www.gnu.org/licenses/>.
 # 
 # Additional permission for code generator templates (*.ftl files)
 # 
 # As a special exception, you may create a larger work that contains part or 
 # all of the MCreator code generator templates (*.ftl files) and distribute 
 # that work under terms of your choice, so long as that work isn't itself a 
 # template for code generation. Alternatively, if you modify or redistribute 
 # the template itself, you may (at your option) remove this special exception, 
 # which will cause the template and the resulting code generator output files 
 # to be licensed under the GNU General Public License without this special 
 # exception.
-->

<#-- @formatter:off -->
<#include "procedures.java.ftl">
<#include "mcitems.ftl">

package ${package}.item;


public class ${name}Item extends Item {

	public ${name}Item() {
		super(new Item.Properties().tab(${data.creativeTab}).stacksTo(${data.stackSize}).rarity(Rarity.${data.rarity})
			.food((new FoodProperties.Builder()).nutrition(${data.nutritionalValue}).saturationMod(${data.saturation}f)
			<#if data.isAlwaysEdible>.alwaysEat()</#if>
			<#if data.forDogs>.meat()</#if>
			.build()));
		setRegistryName("${registryname}");
	}

	<#if data.eatingSpeed != 32>
	@Override public int getUseDuration(ItemStack stack) {
		return ${data.eatingSpeed};
	}
	</#if>

	<#if data.hasGlow>
	@Override public boolean isFoil(ItemStack itemstack) {
		<#if hasProcedure(data.glowCondition)>
		Player entity = Minecraft.getInstance().player;
		Level world = entity.level;
		double x = entity.getX();
		double y = entity.getY();
		double z = entity.getZ();
		return <@procedureOBJToConditionCode data.glowCondition/>;
		<#else>
		return true;
		</#if>
	}
	</#if>

	<#if data.animation != "eat">
	@Override public UseAnim getUseAnimation(ItemStack itemstack) {
		return UseAnim.${data.animation?upper_case};
	}
	</#if>

	<#if data.specialInfo?has_content>
	@Override public void appendHoverText(ItemStack itemstack, Level world, List<Component> list, TooltipFlag flag) {
		super.appendHoverText(itemstack, world, list, flag);
		<#list data.specialInfo as entry>
		list.add(new TextComponent("${JavaConventions.escapeStringForJava(entry)}"));
		</#list>
	}
	</#if>

	<#if hasProcedure(data.onRightClicked)>
	@Override public InteractionResultHolder<ItemStack> use(Level world, Player entity, InteractionHand hand) {
		InteractionResultHolder<ItemStack> ar = super.use(world, entity, hand);
		ItemStack itemstack = ar.getObject();
		double x = entity.getX();
		double y = entity.getY();
		double z = entity.getZ();
		<@procedureOBJToCode data.onRightClicked/>
		return ar;
	}
	</#if>

	<#if hasProcedure(data.onRightClickedOnBlock)>
	@Override public InteractionResult onItemUseFirst(ItemStack itemstack, UseOnContext context) {
		Level world = context.getLevel();
  		BlockPos pos = context.getClickedPos();
  		Player entity = context.getPlayer();
  		Direction direction = context.getClickedFace();
  		BlockState blockstate = world.getBlockState(pos);
		int x = pos.getX();
		int y = pos.getY();
		int z = pos.getZ();
		<#if hasReturnValue(data.onRightClickedOnBlock)>
		return <@procedureOBJToInteractionResultCode data.onRightClickedOnBlock/>;
		<#else>
		<@procedureOBJToCode data.onRightClickedOnBlock/>
		return InteractionResult.PASS;
		</#if>
	}
	</#if>

	<#if hasProcedure(data.onEaten) || (data.resultItem?? && !data.resultItem.isEmpty())>
	@Override public ItemStack finishUsingItem(ItemStack itemstack, Level world, LivingEntity entity) {
		ItemStack retval =
			<#if data.resultItem?? && !data.resultItem.isEmpty()>
				${mappedMCItemToItemStackCode(data.resultItem, 1)};
			</#if>
		super.finishUsingItem(itemstack, world, entity);

		<#if hasProcedure(data.onEaten)>
			double x = entity.getX();
			double y = entity.getY();
			double z = entity.getZ();
			<@procedureOBJToCode data.onEaten/>
		</#if>

		<#if data.resultItem?? && !data.resultItem.isEmpty()>
			if (itemstack.isEmpty()) {
				return retval;
			} else {
				if (entity instanceof Player player && !player.getAbilities().instabuild) {
					if (!player.getInventory().add(retval))
						player.drop(retval, false);
				}
				return itemstack;
			}
		<#else>
			return retval;
		</#if>
	}
	</#if>

	<#if hasProcedure(data.onEntityHitWith)>
	@Override public boolean hurtEnemy(ItemStack itemstack, LivingEntity entity, LivingEntity sourceentity) {
		boolean retval = super.hurtEnemy(itemstack, entity, sourceentity);
		double x = entity.getX();
		double y = entity.getY();
		double z = entity.getZ();
		Level world = entity.level;
		<@procedureOBJToCode data.onEntityHitWith/>
		return retval;
	}
	</#if>

	<#if hasProcedure(data.onEntitySwing)>
	@Override public boolean onEntitySwing(ItemStack itemstack, LivingEntity entity) {
		boolean retval = super.onEntitySwing(itemstack, entity);
		double x = entity.getX();
		double y = entity.getY();
		double z = entity.getZ();
		Level world = entity.level;
		<@procedureOBJToCode data.onEntitySwing/>
		return retval;
	}
	</#if>

	<#if hasProcedure(data.onCrafted)>
	@Override public void onCraftedBy(ItemStack itemstack, Level world, Player entity) {
		super.onCraftedBy(itemstack, world, entity);
		double x = entity.getX();
		double y = entity.getY();
		double z = entity.getZ();
		<@procedureOBJToCode data.onCrafted/>
	}
	</#if>

	<#if hasProcedure(data.onItemInUseTick) || hasProcedure(data.onItemInInventoryTick)>
	@Override public void inventoryTick(ItemStack itemstack, Level world, Entity entity, int slot, boolean selected) {
		super.inventoryTick(itemstack, world, entity, slot, selected);
		double x = entity.getX();
		double y = entity.getY();
		double z = entity.getZ();
		<#if hasProcedure(data.onItemInUseTick)>
		if (selected)
			<@procedureOBJToCode data.onItemInUseTick/>
		</#if>
		<@procedureOBJToCode data.onItemInInventoryTick/>
	}
	</#if>

	<#if hasProcedure(data.onDroppedByPlayer)>
	@Override public boolean onDroppedByPlayer(ItemStack itemstack, Player entity) {
		double x = entity.getX();
		double y = entity.getY();
		double z = entity.getZ();
		Level world = entity.level;
		<@procedureOBJToCode data.onDroppedByPlayer/>
		return true;
	}
	</#if>
}
<#-- @formatter:on -->