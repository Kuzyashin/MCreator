(${input$entity} instanceof LivingEntity _ent_effRem && _ent_effRem.hasEffect(${generator.map(field$potion, "effects")}) ?
    _ent_effRem.getEffect(${generator.map(field$potion, "effects")}).getDuration() : 0)