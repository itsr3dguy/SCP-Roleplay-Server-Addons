import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

Deno.serve(async (req) => {
    // ===== SECURITY CHECK =====
    const SECRET = Deno.env.get("GAME_SECRET");
    const provided = req.headers.get("x-game-secret");
    if (!SECRET || provided !== SECRET) {
        return new Response(JSON.stringify({ error: "Unauthorized" }), { status: 401 });
    }

    const { player, message } = await req.json();
    if (!player || !message) {
        return new Response(JSON.stringify({ error: "Missing player or message" }), { status: 400 });
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
    const newScore = currentScore + 10;

    // Upsert player score
    await supabase
        .from("player_scores")
        .upsert({ player: player, total_score: newScore }, { onConflict: "player" });

    // Log the report
    await supabase
        .from("reports")
        .insert({ player: player, message: message });

    return new Response(JSON.stringify({ success: true, total_score: newScore }), { status: 200 });
});
