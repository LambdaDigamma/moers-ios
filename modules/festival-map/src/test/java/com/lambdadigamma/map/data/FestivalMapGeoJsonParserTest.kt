package com.lambdadigamma.map.data

import com.lambdadigamma.map.data.model.FestivalMapGeometry
import com.lambdadigamma.map.data.model.FestivalMapLayerType
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertIs
import kotlin.test.assertNull

class FestivalMapGeoJsonParserTest {

    private val objectUnderTest = FestivalMapGeoJsonParser()

    @Test
    fun `should parse polygon feature with dorf properties`() {
        val result = objectUnderTest.parseLayer(
            type = FestivalMapLayerType.Dorf,
            rawJson = """
                {
                  "type": "FeatureCollection",
                  "features": [
                    {
                      "type": "Feature",
                      "properties": {
                        "id": 230,
                        "name": "Rollbahn",
                        "type": null,
                        "food": 1,
                        "booth_no": 230,
                        "desc": "Marktfläche"
                      },
                      "geometry": {
                        "type": "Polygon",
                        "coordinates": [
                          [
                            [6.618446, 51.439696],
                            [6.618439, 51.439668],
                            [6.618181, 51.439695],
                            [6.618187, 51.439723],
                            [6.618446, 51.439696]
                          ]
                        ]
                      }
                    }
                  ]
                }
            """.trimIndent(),
        )

        val feature = result.features.single()

        assertEquals("230", feature.id)
        assertEquals("Rollbahn", feature.name)
        assertNull(feature.featureType)
        assertEquals("Marktfläche", feature.description)
        assertEquals(230, feature.boothNumber)
        assertEquals(true, feature.isFood)
        assertIs<FestivalMapGeometry.Polygon>(feature.geometry)
    }

    @Test
    fun `should parse multipolygon geometry`() {
        val result = objectUnderTest.parseLayer(
            type = FestivalMapLayerType.Camping,
            rawJson = """
                {
                  "type": "FeatureCollection",
                  "features": [
                    {
                      "type": "Feature",
                      "properties": {
                        "name": "Camping",
                        "type": "camping"
                      },
                      "geometry": {
                        "type": "MultiPolygon",
                        "coordinates": [
                          [
                            [
                              [6.616746, 51.441207],
                              [6.616498, 51.441150],
                              [6.615913, 51.440990],
                              [6.616746, 51.441207]
                            ]
                          ]
                        ]
                      }
                    }
                  ]
                }
            """.trimIndent(),
        )

        val feature = result.features.single()
        val geometry = assertIs<FestivalMapGeometry.MultiPolygon>(feature.geometry)

        assertEquals("Camping", feature.name)
        assertEquals(1, geometry.polygons.size)
        assertEquals(1, geometry.polygons.first().size)
        assertEquals(4, geometry.polygons.first().first().size)
    }
}
