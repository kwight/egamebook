library edgehead.action_builders;

import 'package:edgehead/fractal_stories/action.dart';
import 'package:edgehead/src/fight/bite/actions/finish_bite.dart';
import 'package:edgehead/src/fight/bite/bite_defense/actions/dodge_bite.dart';
import 'package:edgehead/src/fight/bite/bite_defense/actions/impale_biter.dart';
import 'package:edgehead/src/fight/bite/bite_defense/actions/jump_back_from_bite.dart';
import 'package:edgehead/src/fight/bite/bite_defense/actions/shield_block_bite.dart';
import 'package:edgehead/src/fight/clash/actions/finish_clash.dart';
import 'package:edgehead/src/fight/clash/clash_defense/actions/counter_clash.dart';
import 'package:edgehead/src/fight/clash/clash_defense/actions/withstand_clash.dart';
import 'package:edgehead/src/fight/counter_attack/actions/counter_tackle.dart';
import 'package:edgehead/src/fight/fatality_on_ground/actions/finish_break_neck.dart';
import 'package:edgehead/src/fight/fatality_on_ground/actions/finish_crack_skull.dart';
import 'package:edgehead/src/fight/fatality_on_ground/wrestle_defense/actions/evade_on_ground.dart';
import 'package:edgehead/src/fight/feint/actions/finish_feint.dart';
import 'package:edgehead/src/fight/feint/feint_defense/actions/counter_feint.dart';
import 'package:edgehead/src/fight/feint/feint_defense/actions/withstand_feint.dart';
import 'package:edgehead/src/fight/leap/actions/finish_leap.dart';
import 'package:edgehead/src/fight/leap/leap_defense/actions/dodge_leap.dart';
import 'package:edgehead/src/fight/leap/leap_defense/actions/impale_leaper.dart';
import 'package:edgehead/src/fight/loot/actions/autoloot.dart';
import 'package:edgehead/src/fight/off_balance_opportunity/actions/off_balance_opportunity_thrust.dart';
import 'package:edgehead/src/fight/punch/actions/finish_punch.dart';
import 'package:edgehead/src/fight/punch/punch_defense/actions/dodge_punch.dart';
import 'package:edgehead/src/fight/slash/actions/finish_slash.dart';
import 'package:edgehead/src/fight/slash/slash_defense/actions/defensive_parry_slash.dart';
import 'package:edgehead/src/fight/slash/slash_defense/actions/dodge_slash.dart';
import 'package:edgehead/src/fight/slash/slash_defense/actions/jump_back.dart';
import 'package:edgehead/src/fight/slash/slash_defense/actions/parry_slash.dart';
import 'package:edgehead/src/fight/slash/slash_defense/actions/shield_block_slash.dart';
import 'package:edgehead/src/fight/strike_down/actions/finish_strike_down.dart';
import 'package:edgehead/src/fight/strike_down/actions/finish_thrust_spear_down.dart';
import 'package:edgehead/src/fight/strike_down/strike_down_defense/actions/on_ground_parry.dart';
import 'package:edgehead/src/fight/strike_down/strike_down_defense/actions/on_ground_shield_block.dart';
import 'package:edgehead/src/fight/strike_down/strike_down_defense/actions/roll_out_of_way.dart';
import 'package:edgehead/src/fight/sweep_feet/actions/finish_sweep_feet.dart';
import 'package:edgehead/src/fight/sweep_feet/sweep_feet_defense/actions/avoid_sweep_feet.dart';
import 'package:edgehead/src/fight/sweep_feet/sweep_feet_defense/actions/counter_sweep_feet.dart';
import 'package:edgehead/src/fight/throw/actions/finish_throw_blunt.dart';
import 'package:edgehead/src/fight/throw/actions/finish_throw_thrusting.dart';
import 'package:edgehead/src/fight/throw/throw_defense/actions/catch_projectile.dart';
import 'package:edgehead/src/fight/throw/throw_defense/actions/dodge_throw.dart';
import 'package:edgehead/src/fight/throw/throw_defense/actions/shield_block_throw.dart';
import 'package:edgehead/src/fight/thrust/actions/finish_thrust.dart';
import 'package:edgehead/src/fight/thrust/thrust_defense/actions/dodge_thrust.dart';
import 'package:edgehead/src/fight/thrust/thrust_defense/actions/jump_back.dart';
import 'package:edgehead/src/fight/thrust/thrust_defense/actions/shield_block_thrust.dart';
import 'package:egamebook_builder/instance_serializer.dart';

part 'edgehead_action_builders_gather.gathered.dart';

@GatherInstancesFrom(['lib/src/fight/**/actions/*.dart'],
    additionalTypes: [OtherActorAction, EnemyTargetAction])
final InstanceSerializer<Action> actionSerializer = _$actionSerializer;
