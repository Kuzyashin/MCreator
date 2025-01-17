<#--
 # MCreator (https://mcreator.net/)
 # Copyright (C) 2020 Pylo and contributors
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

package ${package}.block;

import net.minecraft.block.material.Material;
import net.minecraft.entity.ai.attributes.Attributes;

@${JavaModName}Elements.ModElement.Tag public class ${name}Block extends ${JavaModName}Elements.ModElement{

	@ObjectHolder("${modid}:${registryname}")
	public static final FlowingFluidBlock block = null;

	@ObjectHolder("${modid}:${registryname}_bucket")
	public static final Item bucket = null;

	public static FlowingFluid flowing = null;
	public static FlowingFluid still = null;

	private ForgeFlowingFluid.Properties fluidproperties = null;

	public ${name}Block (${JavaModName}Elements instance) {
		super(instance, ${data.getModElement().getSortID()});

		FMLJavaModLoadingContext.get().getModEventBus().register(new FluidRegisterHandler());

		<#if (data.spawnWorldTypes?size > 0)>
		MinecraftForge.EVENT_BUS.register(this);
		FMLJavaModLoadingContext.get().getModEventBus().register(new FeatureRegisterHandler());
		</#if>
	}

	private static class FluidRegisterHandler {

		@SubscribeEvent public void registerFluids(RegistryEvent.Register<Fluid> event) {
			event.getRegistry().register(still);
			event.getRegistry().register(flowing);
		}

	}

	@Override @OnlyIn(Dist.CLIENT) public void clientLoad(FMLClientSetupEvent event) {
		RenderTypeLookup.setRenderLayer(still, RenderType.getTranslucent());
		RenderTypeLookup.setRenderLayer(flowing, RenderType.getTranslucent());
	}

	@Override public void initElements() {
		fluidproperties = new ForgeFlowingFluid.Properties(() -> still, () -> flowing,
				<#if data.extendsFluidAttributes()>Custom</#if>FluidAttributes
				.builder(new ResourceLocation("${modid}:blocks/${data.textureStill}"), new ResourceLocation("${modid}:blocks/${data.textureFlowing}"))
					.luminosity(${data.luminosity})
					.density(${data.density})
					.viscosity(${data.viscosity})
					.temperature(${data.temperature})
					<#if data.isGas>.gaseous()</#if>
					.rarity(Rarity.${data.rarity})
					<#if data.emptySound?has_content && data.emptySound.getMappedValue()?has_content>
					.sound(ForgeRegistries.SOUND_EVENTS.getValue(new ResourceLocation("${data.emptySound}")))
					</#if>
					<#if data.isFluidTinted()>
					.color(<#if data.tintType == "Grass">
						-6506636
						<#elseif data.tintType == "Foliage">
						-12012264
						<#elseif data.tintType == "Water">
						-13083194
						<#elseif data.tintType == "Sky">
						-8214273
						<#elseif data.tintType == "Fog">
						-4138753
						<#else>
						-16448205
						</#if>)
					</#if>)
					.explosionResistance(${data.resistance}f)
					<#if data.canMultiply>.canMultiply()</#if>
					.tickRate(${data.flowRate})
					.levelDecreasePerBlock(${data.levelDecrease})
					.slopeFindDistance(${data.slopeFindDistance})
                    <#if data.generateBucket>.bucket(() -> bucket)</#if>
					.block(() -> block);

		<#if data.extendsForgeFlowingFluid()>
		still = (FlowingFluid) new CustomFlowingFluid.Source(fluidproperties).setRegistryName("${registryname}");
		flowing = (FlowingFluid) new CustomFlowingFluid.Flowing(fluidproperties).setRegistryName("${registryname}_flowing");
		<#else>
		still = (FlowingFluid) new ForgeFlowingFluid.Source(fluidproperties).setRegistryName("${registryname}");
		flowing = (FlowingFluid) new ForgeFlowingFluid.Flowing(fluidproperties).setRegistryName("${registryname}_flowing");
		</#if>

		elements.blocks.add(() -> new FlowingFluidBlock(still,
			<#if generator.map(data.colorOnMap, "mapcolors") != "DEFAULT">
			Block.Properties.create(Material.${data.type}, MaterialColor.${generator.map(data.colorOnMap, "mapcolors")})
			<#else>
			Block.Properties.create(Material.${data.type})
			</#if>
			.hardnessAndResistance(${data.resistance}f)
			<#if data.emissiveRendering>
			.setNeedsPostProcessing((bs, br, bp) -> true).setEmmisiveRendering((bs, br, bp) -> true)
			</#if>
			.setLightLevel(s -> ${data.luminance})
			){
			<#if data.flammability != 0>
			@Override public int getFlammability(BlockState state, IBlockReader world, BlockPos pos, Direction face) {
				return ${data.flammability};
			}
			</#if>

			<#if data.fireSpreadSpeed != 0>
			@Override public int getFireSpreadSpeed(BlockState state, IBlockReader world, BlockPos pos, Direction face) {
				return ${data.fireSpreadSpeed};
			}
			</#if>

			<#if data.lightOpacity == 0>
			@Override
			public boolean propagatesSkylightDown(BlockState state, IBlockReader reader, BlockPos pos) {
				return true;
			}
			<#elseif data.lightOpacity != 1>
			@Override
			public int getOpacity(BlockState state, IBlockReader worldIn, BlockPos pos) {
				return ${data.lightOpacity};
			}
			</#if>

			<#if hasProcedure(data.onBlockAdded) || hasProcedure(data.onTickUpdate)>
			@Override public void onBlockAdded(BlockState blockstate, World world, BlockPos pos, BlockState oldState, boolean moving) {
				super.onBlockAdded(blockstate, world, pos, oldState, moving);
				int x = pos.getX();
				int y = pos.getY();
				int z = pos.getZ();
				<#if hasProcedure(data.onTickUpdate)>
				world.getPendingBlockTicks().scheduleTick(new BlockPos(x, y, z), this, ${data.tickRate});
				</#if>
				<@procedureOBJToCode data.onBlockAdded/>
			}
            </#if>

			<#if hasProcedure(data.onNeighbourChanges)>
			public void neighborChanged(BlockState blockstate, World world, BlockPos pos, Block neighborBlock, BlockPos fromPos, boolean moving) {
				super.neighborChanged(blockstate, world, pos, neighborBlock, fromPos, moving);
				int x = pos.getX();
				int y = pos.getY();
				int z = pos.getZ();
				<@procedureOBJToCode data.onNeighbourChanges/>
			}
			</#if>

			<#if hasProcedure(data.onTickUpdate)>
			@Override public void tick(BlockState blockstate, ServerWorld world, BlockPos pos, Random random) {
				super.tick(blockstate, world, pos, random);
				int x = pos.getX();
				int y = pos.getY();
				int z = pos.getZ();
				<@procedureOBJToCode data.onTickUpdate/>
				world.getPendingBlockTicks().scheduleTick(new BlockPos(x, y, z), this, ${data.tickRate});
			}
			</#if>

			<#if hasProcedure(data.onEntityCollides)>
			@Override public void onEntityCollision(BlockState blockstate, World world, BlockPos pos, Entity entity) {
				super.onEntityCollision(blockstate, world, pos, entity);
				int x = pos.getX();
				int y = pos.getY();
				int z = pos.getZ();
    			<@procedureOBJToCode data.onEntityCollides/>
			}
			</#if>

			<#if hasProcedure(data.onRandomUpdateEvent)>
			@OnlyIn(Dist.CLIENT) @Override
			public void animateTick(BlockState blockstate, World world, BlockPos pos, Random random) {
				super.animateTick(blockstate, world, pos, random);
				PlayerEntity entity = Minecraft.getInstance().player;
				int x = pos.getX();
				int y = pos.getY();
				int z = pos.getZ();
				<@procedureOBJToCode data.onRandomUpdateEvent/>
			}
			</#if>

			<#if hasProcedure(data.onDestroyedByExplosion)>
			@Override public void onExplosionDestroy(World world, BlockPos pos, Explosion e) {
				super.onExplosionDestroy(world, pos, e);
				int x = pos.getX();
				int y = pos.getY();
				int z = pos.getZ();
				<@procedureOBJToCode data.onDestroyedByExplosion/>
			}
			</#if>
		}.setRegistryName("${registryname}"));

		<#if data.generateBucket>
		elements.items.add(() -> new BucketItem(still, new Item.Properties().containerItem(Items.BUCKET).maxStackSize(1)
			<#if data.creativeTab??>.group(${data.creativeTab})<#else>.group(ItemGroup.MISC)</#if>.rarity(Rarity.${data.rarity}))
			<#if data.specialInfo?has_content>{
			@Override @OnlyIn(Dist.CLIENT) public void addInformation(ItemStack itemstack, World world, List<ITextComponent> list, ITooltipFlag flag) {
				super.addInformation(itemstack, world, list, flag);
				<#list data.specialInfo as entry>
				list.add(new StringTextComponent("${JavaConventions.escapeStringForJava(entry)}"));
			</#list>
			}
			}</#if>.setRegistryName("${registryname}_bucket"));
		</#if>
	}

	<#if data.extendsForgeFlowingFluid()>
	public static abstract class CustomFlowingFluid extends ForgeFlowingFluid {
		public CustomFlowingFluid(Properties properties) {
			super(properties);
		}

		<#if data.spawnParticles>
		@OnlyIn(Dist.CLIENT)
		@Override
		public IParticleData getDripParticleData() {
			return ${data.dripParticle};
		}
		</#if>

		<#if data.flowStrength != 1>
		@Override public Vector3d getFlow(IBlockReader world, BlockPos pos, FluidState fluidstate) {
			return super.getFlow(world, pos, fluidstate).scale(${data.flowStrength});
		}
		</#if>

		<#if hasProcedure(data.flowCondition)>
		@Override protected boolean canFlow(IBlockReader worldIn, BlockPos fromPos, BlockState blockstate, Direction direction, BlockPos toPos, BlockState intostate, FluidState toFluidState, Fluid fluidIn) {
			boolean condition = true;
			if (worldIn instanceof IWorld) {
				int x = fromPos.getX();
				int y = fromPos.getY();
				int z = fromPos.getZ();
				IWorld world = (IWorld) worldIn;
				condition = <@procedureOBJToConditionCode data.flowCondition/>;
			}
			return super.canFlow(worldIn, fromPos, blockstate, direction, toPos, intostate, toFluidState, fluidIn) && condition;
		}
		</#if>

		<#if hasProcedure(data.beforeReplacingBlock)>
        @Override protected void beforeReplacingBlock(IWorld world, BlockPos pos, BlockState blockstate) {
        	int x = pos.getX();
        	int y = pos.getY();
        	int z = pos.getZ();
        	<@procedureOBJToCode data.beforeReplacingBlock/>
        }
        </#if>

		public static class Source extends CustomFlowingFluid {
			public Source(Properties properties) {
				super(properties);
			}

			public int getLevel(FluidState state) {
				return 8;
			}

			public boolean isSource(FluidState state) {
				return true;
			}
		}

		public static class Flowing extends CustomFlowingFluid {
			public Flowing(Properties properties) {
				super(properties);
			}

			protected void fillStateContainer(StateContainer.Builder<Fluid, FluidState> builder) {
				super.fillStateContainer(builder);
				builder.add(LEVEL_1_8);
			}

			public int getLevel(FluidState state) {
				return state.get(LEVEL_1_8);
			}

			public boolean isSource(FluidState state) {
				return false;
			}
		}
	}
	</#if>

	<#if data.extendsFluidAttributes()>
	public static class CustomFluidAttributes extends FluidAttributes {
		public static class CustomBuilder extends FluidAttributes.Builder {
			protected CustomBuilder(ResourceLocation stillTexture, ResourceLocation flowingTexture,
					BiFunction<FluidAttributes.Builder, Fluid, FluidAttributes> factory) {
				super(stillTexture, flowingTexture, factory);
			}
		}

		protected CustomFluidAttributes(CustomFluidAttributes.Builder builder, Fluid fluid) {
			super(builder, fluid);
		}

		public static CustomBuilder builder(ResourceLocation stillTexture, ResourceLocation flowingTexture) {
			return new CustomBuilder(stillTexture, flowingTexture, CustomFluidAttributes::new);
		}

		<#if data.isFluidTinted()>
		@Override
		public int getColor(IBlockDisplayReader world, BlockPos pos) {
			return
			<#if data.tintType == "Grass">
				BiomeColors.getGrassColor(world, pos)
			<#elseif data.tintType == "Foliage">
				BiomeColors.getFoliageColor(world, pos)
			<#elseif data.tintType == "Water">
				BiomeColors.getWaterColor(world, pos)
			<#elseif data.tintType == "Sky">
				Minecraft.getInstance().world.getBiome(pos).getSkyColor()
			<#elseif data.tintType == "Fog">
				Minecraft.getInstance().world.getBiome(pos).getFogColor()
			<#else>
				Minecraft.getInstance().world.getBiome(pos).getWaterFogColor()
			</#if>| 0xFF000000;
		}
		</#if>
	}
	</#if>

	<#if (data.spawnWorldTypes?size > 0)>
	private static Feature<BlockStateFeatureConfig> feature = null;
	private static ConfiguredFeature<?, ?> configuredFeature = null;

	private static class FeatureRegisterHandler {

		@SubscribeEvent public void registerFeature(RegistryEvent.Register<Feature<?>> event) {
			feature = new LakesFeature(BlockStateFeatureConfig.field_236455_a_) {
				@Override public boolean generate(ISeedReader world, ChunkGenerator generator, Random rand, BlockPos pos, BlockStateFeatureConfig config) {
					RegistryKey<World> dimensionType = world.getWorld().getDimensionKey();
					boolean dimensionCriteria = false;

    				<#list data.spawnWorldTypes as worldType>
						<#if worldType=="Surface">
							if(dimensionType == World.OVERWORLD)
								dimensionCriteria = true;
						<#elseif worldType=="Nether">
							if(dimensionType == World.THE_NETHER)
								dimensionCriteria = true;
						<#elseif worldType=="End">
							if(dimensionType == World.THE_END)
								dimensionCriteria = true;
						<#else>
							if(dimensionType == RegistryKey.getOrCreateKey(Registry.WORLD_KEY,
									new ResourceLocation("${generator.getResourceLocationForModElement(worldType.toString().replace("CUSTOM:", ""))}")))
								dimensionCriteria = true;
						</#if>
					</#list>

					if(!dimensionCriteria)
						return false;

					<#if hasProcedure(data.generateCondition)>
					int x = pos.getX();
					int y = pos.getY();
					int z = pos.getZ();
					if (!<@procedureOBJToConditionCode data.generateCondition/>)
						return false;
					</#if>

					return super.generate(world, generator, rand, pos, config);
				}
			};

			configuredFeature = feature
					.withConfiguration(new BlockStateFeatureConfig(block.getDefaultState()))
					.withPlacement(Placement.WATER_LAKE.configure(new ChanceConfig(${data.frequencyOnChunks})));

			event.getRegistry().register(feature.setRegistryName("${registryname}_lakes"));
			Registry.register(WorldGenRegistries.CONFIGURED_FEATURE, new ResourceLocation("${modid}:${registryname}_lakes"), configuredFeature);
		}

	}

	@SubscribeEvent public void addFeatureToBiomes(BiomeLoadingEvent event) {
		<#if data.restrictionBiomes?has_content>
				boolean biomeCriteria = false;
			<#list data.restrictionBiomes as restrictionBiome>
				<#if restrictionBiome.canProperlyMap()>
					if (new ResourceLocation("${restrictionBiome}").equals(event.getName()))
						biomeCriteria = true;
				</#if>
			</#list>
				if (!biomeCriteria)
					return;
		</#if>

		event.getGeneration().getFeatures(GenerationStage.Decoration.LOCAL_MODIFICATIONS)
				.add(() -> configuredFeature);
	}
	</#if>

}
<#-- @formatter:on -->