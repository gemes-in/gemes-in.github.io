$ErrorActionPreference = 'Stop'

$workspaceRoot = Split-Path -Parent $PSScriptRoot
$projectRoot = $PSScriptRoot
$sitemapPath = Join-Path $workspaceRoot 'sitemap.xml'
$apiUrl = 'https://jkt48.com/api/v1/members?lang=id'
$baseUrl = 'https://gemes.in/JKT48-PM-Downloader'

function Convert-ToSlug {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Value
    )

    $slug = $Value.ToLowerInvariant()
    $slug = $slug -replace '[^a-z0-9]+', '-'
    $slug = $slug.Trim('-')

    if ([string]::IsNullOrWhiteSpace($slug)) {
        throw "Unable to create slug for value: $Value"
    }

    return $slug
}

function New-HtmlPage {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Title,
        [Parameter(Mandatory = $true)]
        [string]$Description,
        [Parameter(Mandatory = $true)]
        [string]$CanonicalUrl,
        [Parameter(Mandatory = $true)]
        [string]$OgTitle,
        [Parameter(Mandatory = $true)]
        [string]$OgDescription,
        [string]$ExtraHead = '',
        [Parameter(Mandatory = $true)]
        [string]$BodyHtml
    )

@"
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>$Title</title>
    <meta name="description" content="$Description">
    <meta name="robots" content="index,follow,max-image-preview:large,max-snippet:-1,max-video-preview:-1">
    <link rel="canonical" href="$CanonicalUrl">
    <meta property="og:title" content="$OgTitle">
    <meta property="og:description" content="$OgDescription">
    <meta property="og:image" content="https://gemes.in/assets/images/x_meta_pm.png">
    <meta property="og:url" content="$CanonicalUrl">
    <meta property="og:type" content="website">
    <meta name="twitter:card" content="summary_large_image">
    <meta name="twitter:title" content="$OgTitle">
    <meta name="twitter:description" content="$OgDescription">
    <meta name="twitter:image" content="https://gemes.in/assets/images/x_meta_pm.png">
    <link rel="icon" href="/assets/images/pmlogo.webp" type="image/x-icon">
$ExtraHead
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;600;700;800&display=swap" rel="stylesheet">
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    fontFamily: { sans: ['Plus Jakarta Sans', 'sans-serif'] },
                    colors: { iosPink: '#ff4d6d', tgBlue: '#0088cc' }
                }
            }
        }
    </script>
    <style>
        body { background: #f2f2f7; color: #1d1d1f; scroll-behavior: smooth; }
        .glass-card {
            background: rgba(255, 255, 255, 0.72);
            backdrop-filter: blur(20px);
            -webkit-backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.3);
        }
        .ios-gradient-text {
            background: linear-gradient(180deg, #ff4d6d 0%, #c31432 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }
    </style>
</head>
<body class="antialiased font-sans">
$BodyHtml
</body>
</html>
"@
}

function ConvertTo-JsonLd {
    param(
        [Parameter(Mandatory = $true)]
        [object]$InputObject
    )

    $json = $InputObject | ConvertTo-Json -Depth 10
    return "<script type=""application/ld+json"">`n$json`n</script>"
}

function New-Nav {
@"
    <nav class="fixed top-0 w-full z-50 bg-white/60 backdrop-blur-xl border-b border-gray-100 px-6 py-4">
        <div class="max-w-5xl mx-auto flex justify-between items-center">
            <a href="/JKT48-PM-Downloader/" class="font-extrabold text-xl tracking-tighter text-iosPink italic">JKT48 PM DL</a>
            <a href="https://t.me/jeketipmdl_bot" class="bg-tgBlue text-white text-[11px] font-bold px-5 py-2.5 rounded-full shadow-lg shadow-tgBlue/20 active:scale-95 transition uppercase">Mulai Chat</a>
        </div>
    </nav>
"@
}

function New-MemberPageBody {
    param(
        [Parameter(Mandatory = $true)]
        [pscustomobject]$Member,
        [Parameter(Mandatory = $true)]
        [pscustomobject[]]$RelatedMembers
    )

    $relatedLinks = ($RelatedMembers | ForEach-Object {
        "<a href=""/JKT48-PM-Downloader/$($_.slug)/"" class=""block text-iosPink font-bold"">Cara Download PM $($_.nickname) JKT48</a>"
    }) -join "`n                    "

@"
$(New-Nav)
    <main class="pt-32 pb-20 px-6">
        <section class="max-w-5xl mx-auto">
            <a href="/JKT48-PM-Downloader/members/" class="text-xs font-bold uppercase tracking-[0.2em] text-gray-400">PM Member JKT48</a>
            <div class="mt-6 grid grid-cols-1 lg:grid-cols-[1.15fr_0.85fr] gap-8 items-start">
                <div>
                    <h1 class="text-4xl md:text-6xl font-extrabold tracking-tight leading-[1.08]">Cara Download PM <span class="ios-gradient-text italic">$($Member.nickname) JKT48.</span></h1>
                    <p class="mt-6 text-sm md:text-base text-gray-500 max-w-2xl leading-relaxed">Buat fans $($Member.nickname) yang ingin menyimpan foto HD, video, atau voice note dari Private Message, halaman ini merangkum cara aksesnya dengan lebih praktis dan cepat.</p>
                    <div class="mt-8 flex flex-wrap gap-3">
                        <a href="https://t.me/jeketipmdl_bot" class="bg-tgBlue text-white text-sm font-bold px-6 py-3 rounded-2xl shadow-lg shadow-tgBlue/20">Buka Bot Telegram</a>
                        <a href="/JKT48-PM-Downloader/" class="bg-white border border-gray-200 text-gray-900 text-sm font-bold px-6 py-3 rounded-2xl">Lihat Halaman Utama</a>
                    </div>
                </div>
                <div class="glass-card rounded-[34px] p-7 shadow-sm">
                    <p class="text-[10px] font-black tracking-[0.2em] uppercase text-gray-400">Untuk Fans $($Member.nickname)</p>
                    <div class="mt-5 space-y-4 text-sm text-gray-500 leading-relaxed">
                        <p>Pencarian seperti cara download PM $($Member.nickname) JKT48 biasanya datang dari fans yang ingin menyimpan media sebelum masa aktif habis.</p>
                        <p>Halaman ini fokus ke alur yang sederhana: pilih member, aktifkan akses, lalu simpan media yang kamu butuhkan.</p>
                    </div>
                </div>
            </div>
        </section>
        <section class="max-w-5xl mx-auto mt-10">
            <div class="glass-card rounded-[34px] p-8 md:p-10 shadow-sm">
                <h2 class="text-2xl font-bold text-gray-800">Cara Simpan PM $($Member.nickname) JKT48</h2>
                <div class="mt-5 space-y-4 text-sm text-gray-500 leading-relaxed">
                    <p>Langkah pertama adalah membuka bot JKT48 PM Downloader. Dari sana kamu bisa memilih $($Member.nickname) sebagai member yang ingin diakses, lalu melanjutkan ke paket yang sesuai.</p>
                    <p>Setelah akses aktif, kamu bisa mulai menyimpan foto, video, dan voice note yang tersedia. Alur ini cocok untuk fans yang mencari cara download PM $($Member.nickname) JKT48 tanpa harus repot dengan screenshot atau metode manual lain.</p>
                </div>
            </div>
        </section>
        <section class="max-w-5xl mx-auto mt-10">
            <div class="glass-card rounded-[34px] p-8 shadow-sm">
                <h2 class="text-2xl font-bold text-gray-800">Member Lainnya</h2>
                <div class="mt-5 space-y-3 text-sm">
                    $relatedLinks
                    <a href="/JKT48-PM-Downloader/members/" class="block text-iosPink font-bold">Lihat Direktori Member</a>
                </div>
            </div>
        </section>
    </main>
"@
}

function New-MembersDirectoryBody {
    param(
        [Parameter(Mandatory = $true)]
        [pscustomobject[]]$Members
    )

    $memberCards = ($Members | ForEach-Object {
@"
            <a href="/JKT48-PM-Downloader/$($_.slug)/" class="glass-card rounded-[34px] p-7 shadow-sm hover:shadow-lg transition">
                <p class="text-[10px] font-black uppercase tracking-[0.2em] text-iosPink">$($_.type)</p>
                <h2 class="mt-3 text-2xl font-bold text-gray-800">Cara Download PM $($_.nickname) JKT48</h2>
                <p class="mt-3 text-sm text-gray-500 leading-relaxed">Panduan khusus untuk fans $($_.nickname) yang ingin menyimpan media PM dengan lebih praktis.</p>
            </a>
"@
    }) -join "`n"

@"
$(New-Nav)
    <main class="pt-32 pb-16 px-6">
        <section class="max-w-5xl mx-auto text-center">
            <p class="text-[11px] font-black tracking-[0.25em] uppercase text-gray-400">Member Directory</p>
            <h1 class="mt-5 text-4xl md:text-6xl font-extrabold tracking-tight leading-[1.08]">
                Cari Halaman PM <span class="ios-gradient-text italic">Member Favoritmu.</span>
            </h1>
            <p class="mt-6 max-w-2xl mx-auto text-sm md:text-base text-gray-500 leading-relaxed">
                Kami siapkan halaman khusus member JKT48 dan trainee supaya pencarian berdasarkan nickname bisa langsung menuju halaman yang lebih relevan.
            </p>
        </section>
        <section class="max-w-5xl mx-auto mt-12 grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6">
$memberCards
        </section>
    </main>
"@
}

function New-MemberPageStructuredData {
    param(
        [Parameter(Mandatory = $true)]
        [pscustomobject]$Member
    )

    $pageUrl = "$baseUrl/$($Member.slug)/"
    $data = @{
        '@context' = 'https://schema.org'
        '@graph' = @(
            @{
                '@type' = 'WebPage'
                name = "Cara Download PM $($Member.nickname) JKT48"
                url = $pageUrl
                description = "Panduan cara download PM $($Member.nickname) JKT48 untuk simpan foto HD, video, dan voice note dari JKT48 Private Message."
                inLanguage = 'id-ID'
            },
            @{
                '@type' = 'BreadcrumbList'
                itemListElement = @(
                    @{
                        '@type' = 'ListItem'
                        position = 1
                        name = 'JKT48 PM Downloader'
                        item = "$baseUrl/"
                    },
                    @{
                        '@type' = 'ListItem'
                        position = 2
                        name = 'PM Member JKT48'
                        item = "$baseUrl/members/"
                    },
                    @{
                        '@type' = 'ListItem'
                        position = 3
                        name = "$($Member.nickname) JKT48"
                        item = $pageUrl
                    }
                )
            },
            @{
                '@type' = 'FAQPage'
                mainEntity = @(
                    @{
                        '@type' = 'Question'
                        name = "Bagaimana cara download PM $($Member.nickname) JKT48?"
                        acceptedAnswer = @{
                            '@type' = 'Answer'
                            text = "Cara praktisnya adalah membuka bot JKT48 PM Downloader, memilih $($Member.nickname), mengaktifkan akses, lalu mengunduh foto, video, dan voice note yang tersedia."
                        }
                    },
                    @{
                        '@type' = 'Question'
                        name = "Apakah PM $($Member.nickname) JKT48 bisa disimpan ke galeri?"
                        acceptedAnswer = @{
                            '@type' = 'Answer'
                            text = "Bisa. Setelah akses aktif, media PM $($Member.nickname) JKT48 dapat diunduh dan disimpan ke perangkat pribadi."
                        }
                    },
                    @{
                        '@type' = 'Question'
                        name = "Apakah ada foto, video, dan voice note di PM $($Member.nickname) JKT48?"
                        acceptedAnswer = @{
                            '@type' = 'Answer'
                            text = "Halaman ini dibuat untuk kebutuhan download foto, video, dan voice note PM $($Member.nickname) JKT48 dengan alur yang lebih praktis."
                        }
                    }
                )
            }
        )
    }

    return ConvertTo-JsonLd -InputObject $data
}

function New-MembersDirectoryStructuredData {
    param(
        [Parameter(Mandatory = $true)]
        [pscustomobject[]]$Members
    )

    $itemList = @()
    $position = 1
    foreach ($member in $Members) {
        $itemList += @{
            '@type' = 'ListItem'
            position = $position
            url = "$baseUrl/$($member.slug)/"
            name = "Cara Download PM $($member.nickname) JKT48"
        }
        $position++
    }

    $data = @{
        '@context' = 'https://schema.org'
        '@graph' = @(
            @{
                '@type' = 'CollectionPage'
                name = 'PM Member JKT48'
                url = "$baseUrl/members/"
                description = 'Kumpulan halaman member untuk pencarian cara download PM JKT48 berdasarkan nickname.'
                inLanguage = 'id-ID'
            },
            @{
                '@type' = 'ItemList'
                itemListElement = $itemList
            }
        )
    }

    return ConvertTo-JsonLd -InputObject $data
}

function Remove-StaleMemberDirectories {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$ValidSlugs
    )

    $keepDirectories = @('members') + $ValidSlugs
    $projectDirectories = Get-ChildItem -Path $projectRoot -Directory

    foreach ($directory in $projectDirectories) {
        if ($keepDirectories -notcontains $directory.Name) {
            Remove-Item -Path $directory.FullName -Recurse -Force
        }
    }
}

$response = Invoke-RestMethod -Uri $apiUrl
$members = @($response.data | Where-Object { $_.nickname } | ForEach-Object {
    [pscustomobject]@{
        nickname = $_.nickname.Trim()
        type = $_.type
        slug = Convert-ToSlug $_.nickname
    }
} | Sort-Object nickname -Unique)

if ($members.Count -eq 0) {
    throw 'No member nicknames returned from API.'
}

foreach ($member in $members) {
    $memberDir = Join-Path $projectRoot $member.slug
    New-Item -ItemType Directory -Path $memberDir -Force | Out-Null

    $relatedMembers = $members | Where-Object { $_.slug -ne $member.slug } | Select-Object -First 3
    $html = New-HtmlPage `
        -Title "Cara Download PM $($member.nickname) JKT48 | JKT48 PM Downloader" `
        -Description "Panduan cara download PM $($member.nickname) JKT48 untuk simpan foto HD, video, dan voice note dari JKT48 Private Message dengan lebih praktis." `
        -CanonicalUrl "$baseUrl/$($member.slug)/" `
        -OgTitle "Cara Download PM $($member.nickname) JKT48" `
        -OgDescription "Simpan foto, video, dan voice note PM $($member.nickname) JKT48 dengan langkah yang praktis lewat bot downloader." `
        -ExtraHead (New-MemberPageStructuredData -Member $member) `
        -BodyHtml (New-MemberPageBody -Member $member -RelatedMembers $relatedMembers)

    Set-Content -Path (Join-Path $memberDir 'index.html') -Value $html -Encoding UTF8
}

$membersDir = Join-Path $projectRoot 'members'
New-Item -ItemType Directory -Path $membersDir -Force | Out-Null
$membersHtml = New-HtmlPage `
    -Title "PM Member JKT48 | JKT48 PM Downloader" `
    -Description "Kumpulan halaman PM member JKT48 untuk mencari cara download PM berdasarkan nickname member favorit." `
    -CanonicalUrl "$baseUrl/members/" `
    -OgTitle "PM Member JKT48 | JKT48 PM Downloader" `
    -OgDescription "Cari halaman PM member JKT48 favoritmu dan temukan panduan download media dengan lebih mudah." `
    -ExtraHead (New-MembersDirectoryStructuredData -Members $members) `
    -BodyHtml (New-MembersDirectoryBody -Members $members)
Set-Content -Path (Join-Path $membersDir 'index.html') -Value $membersHtml -Encoding UTF8

Remove-StaleMemberDirectories -ValidSlugs $members.slug

$existingUrlBlocks = [regex]::Matches((Get-Content $sitemapPath -Raw), '<url>.*?</url>', 'Singleline')
$preservedBlocks = foreach ($match in $existingUrlBlocks) {
    if ($match.Value -notmatch '<loc>https://gemes\.in/JKT48-PM-Downloader/') {
        $match.Value
    }
}

$timestamp = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:sszzz')
$generatedBlocks = @()
$generatedBlocks += @"
<url>
  <loc>https://gemes.in/JKT48-PM-Downloader/</loc>
  <lastmod>$timestamp</lastmod>
  <priority>0.80</priority>
</url>
"@
$generatedBlocks += @"
<url>
  <loc>https://gemes.in/JKT48-PM-Downloader/members/</loc>
  <lastmod>$timestamp</lastmod>
  <priority>0.75</priority>
</url>
"@
$generatedBlocks += foreach ($member in $members) {
@"
<url>
  <loc>https://gemes.in/JKT48-PM-Downloader/$($member.slug)/</loc>
  <lastmod>$timestamp</lastmod>
  <priority>0.70</priority>
</url>
"@
}

$sitemap = @(
    '<?xml version="1.0" encoding="UTF-8"?>'
    '<urlset'
    '      xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"'
    '      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"'
    '      xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9'
    '            http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd">'
    ''
    ($preservedBlocks -join "`n")
    ($generatedBlocks -join "`n")
    ''
    '</urlset>'
) -join "`n"

Set-Content -Path $sitemapPath -Value $sitemap -Encoding UTF8

Write-Host "Generated $($members.Count) member pages and updated sitemap."
