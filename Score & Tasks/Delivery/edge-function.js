// Call this edge function delivery-complete

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

Deno.serve(async (req) => {
    const { player } = await req.json();

    if (!player) {
        return new Response(JSON.stringify({ error: "No player provided" }), { status: 400 });
    }

    const supabase = createClient(
        Deno.env.get("SUPABASE_URL")!,
        Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    // Get current total score for this player
    const { data: existing } = await supabase
        .from("player_scores")
        .select("total_score")
        .eq("player", player)
        .single();

    const currentScore = existing?.total_score ?? 0;
    const newScore = currentScore + 5;

    // Upsert player score
    await supabase
        .from("player_scores")
        .upsert({ player: player, total_score: newScore }, { onConflict: "player" });

    // Log the delivery
    await supabase
        .from("deliveries")
        .insert({ player: player, score_awarded: 5 });

    return new Response(JSON.stringify({ success: true, total_score: newScore }), { status: 200 });
});
