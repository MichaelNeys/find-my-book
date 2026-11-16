<script lang="ts">
	import { onMount } from 'svelte';
	import { m } from '#lib/paraglide/messages.js';

	type Status = { state: 'checking' } | { state: 'ok'; version: string } | { state: 'down' };
	let status = $state<Status>({ state: 'checking' });

	onMount(async () => {
		try {
			const response = await fetch('/api/health');
			if (!response.ok) throw new Error(`HTTP ${response.status}`);
			const body: { version: string } = await response.json();
			status = { state: 'ok', version: body.version };
		} catch {
			status = { state: 'down' };
		}
	});
</script>

<svelte:head>
	<title>{m.app_title()}</title>
</svelte:head>

<main class="mx-auto flex min-h-screen max-w-xl flex-col justify-center gap-4 px-4">
	<h1 class="text-4xl font-bold tracking-tight">{m.app_title()}</h1>
	<p class="text-lg text-gray-600">{m.app_tagline()}</p>
	<p class="text-sm">
		<span class="font-medium">{m.api_status_label()}:</span>
		{#if status.state === 'checking'}
			<span class="text-gray-500">{m.api_status_checking()}</span>
		{:else if status.state === 'ok'}
			<span class="text-green-700">{m.api_status_ok({ version: status.version })}</span>
		{:else}
			<span class="text-red-700">{m.api_status_down()}</span>
		{/if}
	</p>
</main>
